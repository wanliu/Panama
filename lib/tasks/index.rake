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
                    },
                    "replace_blank" => {
                      "tokenizer" => "keyword",
                      "filter" => ["replace_blank"]
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
                },
                "filter" => {
                  "replace_blank" => {
                    "type" => "pattern_replace",
                    "pattern" => " ",
                    "replacement" => ""
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
              "first_name" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "analyzer" => "only_analyzer",
                "boost" => 10
              },
              "any_name" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "analyzer" => "none_analyzer",
                "boost" => 10
              },
              "name" => {
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
                    "none_analyzer" => {
                        "tokenizer" => "none_pinyin",
                        "filter" => ["standard"]
                    },
                    "only_analyzer" => {
                        "tokenizer" => "only_pinyin",
                        "filter" => ["standard"]
                    },
                    "replace_blank" => {
                      "tokenizer" => "keyword",
                      "filter" => ["replace_blank"]
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
                },
                "filter" => {
                  "replace_blank" => {
                    "type" => "pattern_replace",
                    "pattern" => " ",
                    "replacement" => ""
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
                    "first_name" => {
                      "type" => "string",
                      "store" => "no",
                      "term_vector" => "with_positions_offsets",
                      "analyzer" => "only_analyzer",
                      "boost" => 10
                    },
                    "any_name" => {
                      "type" => "string",
                      "store" => "no",
                      "term_vector" => "with_positions_offsets",
                      "analyzer" => "none_analyzer",
                      "boost" => 10
                    },
                    "name" => {
                      "type" => "string",
                      "store" => "no",
                      "analyzer" => "replace_blank"
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
              "none_analyzer" => {
                "tokenizer" => "none_pinyin",
                "filter" => ["standard"]
              },
              "only_analyzer" => {
                "tokenizer" => "only_pinyin",
                "filter" => ["standard"]
              },
              "replace_blank" => {
                "tokenizer" => "keyword",
                "filter" => ["replace_blank"]
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
            },
            "filter" => {
              "replace_blank" => {
                "type" => "pattern_replace",
                "pattern" => " ",
                "replacement" => ""
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
              "first_title" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "analyzer" => "only_analyzer",
                "boost" => 10
              },
              "any_title" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "analyzer" => "none_analyzer",
                "boost" => 10
              },
              "title" => {
                "type" => "string",
                "store" => "no",
                "analyzer" => "replace_blank"
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
                  "none_analyzer" => {
                      "tokenizer" => "none_pinyin",
                      "filter" => ["standard"]
                  },
                  "only_analyzer" => {
                      "tokenizer" => "only_pinyin",
                      "filter" => ["standard"]
                  },
                  "replace_blank" => {
                    "tokenizer" => "keyword",
                    "filter" => ["replace_blank"]
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
              },
              "filter" => {
                "replace_blank" => {
                  "type" => "pattern_replace",
                  "pattern" => " ",
                  "replacement" => ""
                }
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
              "first_title" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "analyzer" => "only_analyzer",
                "boost" => 10
              },
              "any_title" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "analyzer" => "none_analyzer",
                "boost" => 10
              },
              "title" => {
                "type" => "string",
                "store" => "no",
                "analyzer" => "replace_blank"
              }
            }
          }
        }
      }
    end
  end
end
