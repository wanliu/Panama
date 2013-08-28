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
                    "none_analyzer" => {
                        "tokenizer" => "none_pinyin",
                        "filter" => ["standard"]
                    },
                    "only_analyzer" => {
                        "tokenizer" => "only_pinyin",
                        "filter" => ["standard"]
                    }
                },
                "tokenizer" => {
                    "none_pinyin" => {
                        "type" => "pinyin",
                        "first_letter" => "none",
                        "padding_char" => ""
                    },
                    "only_pinyin" => {
                        "type" => "pinyin",
                        "first_letter" => "only",
                        "padding_char" => ""
                    }
                }
            }
        }
      })
      sleep 1

      # close
      # put_settings({
      #   "index" => {
      #       "analysis" => {
      #           "analyzer" => {
      #               "pinyin_analyzer" => {
      #                   "tokenizer" => ["my_pinyin"],
      #                   "filter" => ["standard", "nGram"]
      #               }
      #           },
      #           "tokenizer" => {
      #               "my_pinyin" => {
      #                   "type" => "pinyin",
      #                   "first_letter" => "prefix",
      #                   "padding_char" => ""
      #               }
      #           }
      #       }
      #   }
      # })
      # open

      mapping :product, {
        "properties" => {
            "name" => {
                "type" => "multi_field",
                "fields" => {
                    "first_name" => {
                        "type" => "string",
                        "store" => "no",
                        "term_vector" => "with_positions_offsets",
                        "analyzer" => "none_analyzer",
                        "boost" => 10
                    },
                    "any_name" => {
                        "type" => "string",
                        "store" => "no",
                        "term_vector" => "with_positions_offsets",
                        "analyzer" => "only_analyzer",
                        "boost" => 10
                    },
                    "primitive" => {
                        "type" => "string",
                        "store" => "yes",
                        "analyzer" => "keyword"
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
                    "none_analyzer" => {
                        "tokenizer" => "none_pinyin",
                        "filter" => ["standard"]
                    },
                    "only_analyzer" => {
                        "tokenizer" => "only_pinyin",
                        "filter" => ["standard"]
                    }
                },
                "tokenizer" => {
                    "none_pinyin" => {
                        "type" => "pinyin",
                        "first_letter" => "none",
                        "padding_char" => ""
                    },
                    "only_pinyin" => {
                        "type" => "pinyin",
                        "first_letter" => "only",
                        "padding_char" => ""
                    }
                }
            }
        }
      })
      sleep 1

      # close
      # put_settings({
      #   "index" => {
      #       "analysis" => {
      #           "analyzer" => {
      #               "pinyin_analyzer" => {
      #                   "tokenizer" => ["my_pinyin"],
      #                   "filter" => ["standard", "nGram"]
      #               }
      #           },
      #           "tokenizer" => {
      #               "my_pinyin" => {
      #                   "type" => "pinyin",
      #                   "first_letter" => "prefix",
      #                   "padding_char" => ""
      #               }
      #           }
      #       }
      #   }
      # })
      # open

      mapping :shop_product, {
        "properties" => {
            "name" => {
                "type" => "multi_field",
                "fields" => {
                    "first_name" => {
                        "type" => "string",
                        "store" => "no",
                        "term_vector" => "with_positions_offsets",
                        "analyzer" => "none_analyzer",
                        "boost" => 10
                    },
                    "any_name" => {
                        "type" => "string",
                        "store" => "no",
                        "term_vector" => "with_positions_offsets",
                        "analyzer" => "only_analyzer",
                        "boost" => 10
                    },
                    "primitive" => {
                        "type" => "string",
                        "store" => "yes",
                        "analyzer" => "keyword"
                    }
                }
            }
        }
      }
    end
  end
end
