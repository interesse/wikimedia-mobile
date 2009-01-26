module Parsers
  class WML < XHTML
    
    def self.parse(article, options = {})
      html= super(article, options) # Do everything xhtml does like rough cutting of content, setting of page title
      page = Nokogiri::HTML(html)
      cards= []
      card=0
      block=[]
      titles= [article.title]
      page.xpath("//h2|//h3|//p|//li").each do |elem|
        case elem.name
        when "p"
          block<< do_links(elem)
        when "h2"
          #          cards<< "<card id='card_#{card}' title='#{titles[card]}'>#{block.join}</card>" 
          cards<< {:id=>card, :title=>titles[card], :content=>block.join}
          card+=1
          titles<< elem.content
          block=[]
        when "h3"
          block<< "<br/><b><big>#{page.encode_special_chars(elem.content)}</big></b><br/>"
        when "li"
          block<< "<br/>- #{do_links(elem)}<br/>"
        end
      end
      if card>0
        titles[1..-1].each_with_index do |title, index|
          cards[0][:content]<< "<br/>- <a href='#card_#{index+1}'>#{title}</a>"
        end
      end
      unless block.empty?
        #        cards<< "<card id='card_#{card}' title='#{titles[card]}'>#{block.join}</card>"         
        cards<< {:id=>card, :title=>titles[card], :content=>block.join}
      end
      article.html = cards.map do |c|
        "<card id='card_#{c[:id]}' title='#{c[:title]}'>#{c[:content]}</card>" 
      end.join
    end
    private
    def inner(elem)
      case elem.type
      when Nokogiri::XML::Node::TEXT_NODE
#        elem.content= elem.encode_special_chars(elem.content)
      when Nokogiri::XML::Node::ELEMENT_NODE
        case elem.name
        when "p", "a", "br", "b", "strong", "i"
          elem.children.each do |child|
            inner(child)
          end
        else
          elem.children.each do |child|
            inner(child)
            elem.add_next_sibling(child)
          end
          elem.remove
        end
      end
      elem
    end
    
    
    
    
    def self.do_links(elem)
      #      return elem.encode_special_chars(elem.content)
      elem.traverse do |e|
        case e.type
        when Nokogiri::XML::Node::TEXT_NODE
          #          e.content= e.encode_special_chars(e.content)
        when Nokogiri::XML::Node::ELEMENT_NODE
          case e.name
          when "p", "a", "br", "b", "strong", "i"
          else
#            e.replace(Nokogiri::Hpricot.make(e.inner_html))
#            (x/"i")[0].children.each {|e| (x/"i")[0].add_previous_sibling(e); puts x}
            e.children.each do |child|
              Merb.logger.debug "BEFORE #{child}"
              e.add_next_sibling(child)
            end
#            e.remove
#
#
#            inner= e.children
#            inner.each do |inner_elem|
#              #              Merb.logger.debug "INNER #{inner_elem}"
#              e.add_next_sibling(do_links(inner_elem))
#            end
#            e.remove
#            Merb.logger.debug "AFTER #{e.parent}"
          end
        end
      end
      elem
    end
  end
end
