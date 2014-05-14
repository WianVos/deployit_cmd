module Deployit
  module Mixins
    module Xml

      def to_xml(id, type, properties)
        props = {'@id' => id}.merge(properties)
        XmlSimple.xml_out(
            props,
            {
                'RootName' => type,
                'AttrPrefix' => true,
                'GroupTags' => {
                    'tags' => 'value',
                    'servers' => 'ci',
                    'members' => 'ci',
                    'dictionaries' => 'ci',
                    'entries' => 'entry'
                },
            }
        )
      end

      def to_hash(xml)
        normalize XmlSimple.xml_in(
            xml,
            {
                'ForceArray' => false,
                'AttrPrefix' => true,
                'GroupTags' => {
                    'tags'         => 'value',
                    'servers'      => 'ci',
                    'members'      => 'ci',
                    'dictionaries' => 'ci',
                    'entries'      => 'entry'
                },
            }
        )
      end

      def root_element(xml)
        doc = Nokogiri::XML(xml)
        return doc.xpath('/*').first.name
      end

      def normalize(hash)
        new_hash = {}

        hash.each do |k, v|
          if v.class == Hash
            new_hash[k.gsub('@','')] = normalize(v)
          else
            new_hash[k.gsub('@','')] = v
          end
        end
        return new_hash
      end
    end
  end
end