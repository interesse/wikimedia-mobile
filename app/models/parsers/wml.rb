module Parsers
  class WML < XHTML
    
    def self.parse(article, options = {})
      html= super(article, options) # Do everything xhtml does like rough cutting of content, setting of page title
      page = Nokogiri::HTML(html)
      result= ""
      block=[]
      block_title= article.title
      page.xpath("//h2|//h3|//p|//li").each do |elem|
        case elem.name
        when "p"
          block<< do_links(elem)
        when "h2"
          result<< "<card id='' title='#{block_title}'>#{block.join}</card>" 
          block_title= elem.content
          block=[]
        when "h3"
          block<< "<br/><b><big>#{page.encode_special_chars(elem.content)}</big></b><br/>"
        when "li"
          block<< "<br/>- #{do_links(elem.child)}<br/>"
        end
      end
      unless block.empty?
        result<< "<card id='' title='#{block_title}'>#{block.join}</card>"         
      end
      article.html = result
    end
  private
    def self.do_links(elem)
      elem.traverse do |e|
        case e.type
        when Nokogiri::XML::Node::TEXT_NODE
#          e.content= e.encode_special_chars(e.content)
        when Nokogiri::XML::Node::ELEMENT_NODE
          case e.name
          when "p", "a", "br"
          else
#            inner= e.child
#            Merb.logger.debug "#{inner}"
#            e.replace inner
#            e.unlink
          end
        end
      end
      elem
    end
  end
end
