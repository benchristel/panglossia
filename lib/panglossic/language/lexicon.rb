=begin

LEXICON DSL

gedbe : bookstore; bookshop; bookshelf; place to store books
ged   : book
be    : store; shop; storage place

This will create the following index:

{
  "bookstore" => {:synonyms => ["gedbe"]}
  "bookshop" => {:synonyms => ["gedbe"]}
  "bookshelf" => {:synonyms => ["gedbe"]}
  "place" => {:related => ["gedbe", "be"]}
  "store" => {:synonyms => ["be"], :related => ["gedbe"]}
  "books" => {:related => ["gedbe"]}
  "book" => {:synonyms => ["ged"]}
  "shop" => {:synonyms => ["be"]}
  "storage" => {:related => ["be"]}
}

=end

require 'set'

module Panglossic
  module Language
    class Lexicon
      ANY_NEWLINES = /\n+/
      COLON = /\s*:\s*/
      SEMICOLONS = /\s*;\s*/
      WORDS = /\W+/
      
      STOPWORDS = Set.new(%w(a an and for the to))
      
      def stopword? word
        STOPWORDS.include? word
      end
      
      def initialize lexicon_dsl_string = "", options = {}
        @prompt = options[:prompt]
        @warn = options[:warn]
        @logger = options[:logger] || Panglossic::Logger.new(:level => :warn)
        @sca = options[:sound_change_applier] || SoundChangeApplier.new
        
        @index = {}
        @reverse_index = {}
        
        entries = lexicon_dsl_string.split(ANY_NEWLINES)
        entries.each do |entry|
          add_entry entry
        end
      end
      
      def lookup gloss
        unless @index[gloss]
          # gloss isn't in lexicon
          @logger.warn "couldn't find `#{gloss}' among glosses" unless @warn == false
          return gloss
        end
        
        [:synonyms, :related].each do |type|
          if @index[gloss][type]
            if @index[gloss][type].length == 1
              # exactly one match
              return @index[gloss][type][0]
            elsif @index[gloss][type].length > 1
              # multiple matches
              return prompt gloss, @index[gloss][type] unless @prompt == false
              return @index[gloss][type][0]
            end
          end
        end
      end
      
      def reverse_lookup foreign
        unless @reverse_index[foreign]
          # word isn't in lexicon
          @logger.warn "couldn't find `#{foreign}' among foreign words" unless @warn == false
          return foreign
        end
        
        @reverse_index[foreign]
      end
      
      def add_entry entry
        foreign, glosses = entry.split(COLON)
        glosses = glosses.split(SEMICOLONS)
        foreign = sound_change(foreign.strip)
        add_to_reverse_index glosses, foreign
        glosses.each do |gloss|
          gloss = gloss.strip
          related = gloss.split(WORDS)
          if related.length > 1
            related.each do |r|
              add_related r, foreign unless stopword? r
            end
          else
            add_synonym gloss, foreign
          end
        end
      end
      
      def sound_change foreign
        @sca.change(foreign)
      end
      
      def add_related gloss, foreign
        @index[gloss] ||= {}
        @index[gloss][:related] ||= []
        @index[gloss][:related] << foreign
      end
      
      def add_synonym gloss, foreign
        @index[gloss] ||= {}
        @index[gloss][:synonyms] ||= []
        @index[gloss][:synonyms] << foreign
      end
      
      def add_to_reverse_index glosses, foreign
        @reverse_index[foreign] ||= []
        @reverse_index[foreign].concat glosses
      end
    end
  end
end


