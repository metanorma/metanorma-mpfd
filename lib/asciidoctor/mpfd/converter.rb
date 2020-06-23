require "asciidoctor"
require "asciidoctor/mpfd"
require "asciidoctor/standoc/converter"
require "isodoc/mpfd/html_convert"
require "isodoc/mpfd/word_convert"
require_relative "section"
require "fileutils"
require_relative "./validate"

module Asciidoctor
  module Mpfd

    # A {Converter} implementation that generates MPFD output, and a document
    # schema encapsulation of the document for validation
    #
    class Converter < Standoc::Converter
      XML_ROOT_TAG = "mpfd-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.org/ns/mpfd".freeze

      register_for "mpfd"

      def metadata_author(node, xml)
        xml.contributor do |c|
          c.role **{ type: "author" }
          c.organization do |a|
            a.name "Mandatory Provident Fund Schemes Authority"
            a.abbreviation "MPFA"
          end
        end
      end

      def metadata_publisher(node, xml)
        xml.contributor do |c|
          c.role **{ type: "publisher" }
          c.organization do |a|
            a.name "Mandatory Provident Fund Schemes Authority"
            a.abbreviation "MPFA"
          end
        end
      end

      def metadata_committee(node, xml)
        return unless node.attr("committee")
        xml.editorialgroup do |a|
          a.committee node.attr("committee"),
            **attr_code(type: node.attr("committee-type"))
          i = 2
          while node.attr("committee_#{i}") do
            a.committee node.attr("committee_#{i}"),
              **attr_code(type: node.attr("committee-type_#{i}"))
            i += 1
          end
        end
      end

      def metadata_id(node, xml)
        xml.docidentifier { |i| i << node.attr("docnumber") }
        xml.docnumber { |i| i << node.attr("docnumber") }
      end

      def metadata_copyright(node, xml)
        from = node.attr("copyright-year") || Date.today.year
        xml.copyright do |c|
          c.from from
          c.owner do |owner|
            owner.organization do |o|
              o.name "Mandatory Provident Fund Schemes Authority"
              o.abbreviation "MPFA"
            end
          end
        end
      end

      def title_validate(root)
        nil
      end

      def makexml(node)
        @draft = node.attributes.has_key?("draft")
        super
      end

      def outputs(node, ret)
        File.open(@filename + ".xml", "w:UTF-8") { |f| f.write(ret) }
        presentation_xml_converter(node).convert(@filename + ".xml")
        html_converter(node).convert(@filename + ".presentation.xml", nil, false, "#{@filename}.html")
        doc_converter(node).convert(@filename + ".presentation.xml", nil, false, "#{@filename}.doc")
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), "mpfd.rng"))
      end

      def style(n, t)
        return
      end

      def presentation_xml_converter(node)
        IsoDoc::Mpfd::PresentationXMLConvert.new(html_extract_attributes(node))
      end

      def html_converter(node)
        IsoDoc::Mpfd::HtmlConvert.new(html_extract_attributes(node))
      end

      def doc_converter(node)
        IsoDoc::Mpfd::WordConvert.new(doc_extract_attributes(node))
      end
    end
  end
end
