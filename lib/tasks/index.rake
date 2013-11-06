require 'tire'

namespace "index" do
  desc "import pinyin index"
  task :load => :environment do
    Tire.index "products" do
      delete

      create({
        "index" => {
          "analysis" => {
            "analyzer" => {
              "pinyin_analyzer" => {
                "tokenizer" => "my_pinyin",
                "filter" => ["standard", "nGram"]
              }
            },
            "tokenizer" => {
              "my_pinyin" => {
                "type" => "pinyin",
                "first_letter" => "prefix",
                "padding_char" => ""
              }
            }
          }
        }
      })
      sleep 1

      mapping :product, {
        "properties" => {
          "name" => {
            "type" => "multi_field",
            "fields" => {
              "name" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "analyzer" => "pinyin_analyzer",
                "boost" => 10
              },
              "primitive" => {
                "type" => "string",
                "store" => "no",
                "analyzer" => "replace_blank"
              }
            }
          }
        }
      }
    end

    Tire.index "shop_products" do
      delete

      create({
        "index" => {
          "analysis" => {
            "analyzer" => {
              "pinyin_analyzer" => {
                "tokenizer" => "my_pinyin",
                "filter" => ["standard", "nGram"]
              }
            },
            "tokenizer" => {
              "my_pinyin" => {
                "type" => "pinyin",
                "first_letter" => "prefix",
                "padding_char" => ""
              }
            }
          }
        }
      })
      sleep 1

      mapping :shop_product, {
        "properties" => {
          "name" => {
            "type" => "multi_field",
            "fields" => {
              "name" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "analyzer" => "pinyin_analyzer",
                "boost" => 10
              },
              "primitive" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "indexAnalyzer" => "mmseg",
                "searchAnalyzer" => "mmseg",
                "include_in_all" => "true",
                "boost" => 10
              }
            }
          }
        }
      }
    end

    Tire.index "activities" do
      delete

      create({
        "index" => {
          "analysis" => {
            "analyzer" => {
              "pinyin_analyzer" => {
                "tokenizer" => "my_pinyin",
                "filter" => ["standard", "nGram"]
              }
            },
            "tokenizer" => {
              "my_pinyin" => {
                "type" => "pinyin",
                "first_letter" => "prefix",
                "padding_char" => ""
              }
            }
          }
        }
      })

      sleep 1

      mapping :activity, {
        "properties" => {
          "title" => {
            "type" => "multi_field",
            "fields" => {
              "title" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "analyzer" => "pinyin_analyzer",
                "boost" => 10
              },
              "primitive" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "indexAnalyzer" => "mmseg",
                "searchAnalyzer" => "mmseg",
                "include_in_all" => "true",
                "boost" => 10
              }
            }
          }
        }
      }
    end

    Tire.index "ask_buys" do
      delete

      create({
        "index" => {
          "analysis" => {
            "analyzer" => {
              "pinyin_analyzer" => {
                "tokenizer" => "my_pinyin",
                "filter" => ["standard", "nGram"]
              }
            }
          },
          "tokenizer" => {
            "my_pinyin" => {
              "type" => "pinyin",
              "first_letter" => "prefix",
              "padding_char" => ""
            }
          }
        }
      })

      sleep 1

      mapping :ask_buy, {
        "properties" => {
          "title" => {
            "type" => "multi_field",
            "fields" => {
              "title" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "analyzer" => "pinyin_analyzer",
                "boost" => 10
              },
              "primitive" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "indexAnalyzer" => "mmseg",
                "searchAnalyzer" => "mmseg",
                "include_in_all" => "true",
                "boost" => 10
              }
            }
          }
        }
      }
    end
  end
end
