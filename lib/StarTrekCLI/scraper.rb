require 'open-uri/cached'
require 'nokogiri'

module StarTrekCLI
  class Scraper

  DATE_REGEX = /Stardate:\s*(?<stardate>[\d.]+)\s*Original\s*Airdate:\s*(?<airdate>[^\n]+)/i

    # This method pulls information from the Chakoteya index for each Star Trek
    # series using an iterator. The data is constructed as a hash with
    # `image_url`, `page_url`, and `title` properties. This is yielded as a
    # block argument.
    def each_index_group(index_url)
      doc = Nokogiri::HTML(open(index_url))
      table = doc.css("tbody")

      row1 = table.css("tr")[0].css("td a img") # images
      row2 = table.css("tr")[1].css("a") # links

      # works like a do loop
      (0..3).each do |column|
        cell_group = {
          :image_url => row1[column].attr("src"),
          :page_url => row2[column].attr("href"),
          :title => row2[column].children.first.content.strip
        }
        yield cell_group
      end
    end
        
    # This method pulls information from the scraped series using an iterator.
    # The data is constructed as a hash with `episode_name`, `star_date`, and
    # `air_date` properties. This is yielded as a block argument.
    def each_series_page(series_url)
      html_source = open(series_url)
      doc = Nokogiri::HTML(html_source)
      sub_tables = doc.css("body > table table")

      # FIXME: seasons will have some problems like 101 + 102 or the animated
      # series as season "4"
      if sub_tables.empty?
        doc.css("body > div table").each_with_index do |table, index|
          rows = table.css("tr")
          rows.shift
          rows.each do |row|
            link = row.css("td")[0].css("a")

            episode_row = {
              :season_number => index + 1,
              :episode_name => link.children.text.strip,
              :episode_url => link.attr("href").value,
              # I am using to_i to truncate any second set of production numbers
              :production_number => row.css("td")[1].text.strip.to_i.to_s,
            }
            yield episode_row
          end # rows.each
        end #  body > div table

      else # sub_tables is not empty
        sub_tables.each_with_index do |table, index|
          rows = table.css("tr")
          rows.shift
          rows.each do |row|
            link = row.css("td").css("a")

            episode_row = {
              :season_number => index + 1,
              :episode_name => link.children.text.strip,
              :episode_url => link.attr("href").value,
              :production_number => row.css("td")[1].text.strip.to_i.to_s,
            }
            yield episode_row
          end # rows.each
        end # subtables.each
      end # if / else
    end # def each_series_page

    # This method pulls information from the scraped episodes using an iterator.
    # The data is constructed as a hash with `episode_name`, `star_date`, and
    # `air_date` properties. This is yielded as a block argument.
    def episode_page_header(episode_url)

      html_source = open(episode_url)
      doc = Nokogiri::HTML(html_source)
      header = doc.css("body > p").first
      dates = header.children.last.text.match(DATE_REGEX)

     # the star trek pilot does *not* have any dates... it will return
     # nil to the user.
      episode_stuff = {
        :episode_name => header.css("b").text.strip,
        :star_date => dates ? dates[1].strip : nil,
        :air_date => dates ? dates[2].strip : nil
      }
        yield episode_stuff
    end


  end # Scraper
end # module StarTrekCLI
