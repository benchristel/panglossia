module Panglossic
  module Language
    class Base
      def self.lexicon lexicon_dsl_string
        @@singleton.lexicon = Lexicon.new lexicon_dsl_string
      end
      
      def lexicon= lexicon
        @lexicon = lexicon
      end
      
      def self.try_inflect root, inflection
        inflection = inflection.downcase
        if @@singleton.respond_to? inflection
          @@singleton.send inflection, root
        end
      end
      
      @@singleton = new
    end
  end
end
