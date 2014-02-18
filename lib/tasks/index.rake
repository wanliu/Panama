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
                "term_vector" => "with_positions_offsets",
                "indexAnalyzer" => "mmseg",
                "searchAnalyzer" => "mmseg",
                "include_in_all" => "true",
                "boost" => 10
              },
              "untouched" => {
                "type" => "string",
                "index" => "not_analyzed"
              }
            }
          },
          "brand_name" => {
            "type" => "string",
            "index" => "not_analyzed"
          }
        },
        "dynamic_templates" => [{
          "property_template" => {
            "mapping" => {
              "type" => "string",
              "index" => "not_analyzed"
            },
            "path_match" => "properties.*"
          }
        }]
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
              },
              "untouched" => {
                "type" => "string",
                "index" => "not_analyzed"
              }
            }
          }
        },
        "dynamic_templates" => [{
          "property_template" => {
            "mapping" => {
              "type" => "string",
              "index" => "not_analyzed"
            },
            "path_match" => "properties.*"
          }
        }]
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
              },
              "untouched" => {
                "type" => "string",
                "index" => "not_analyzed"
              }
            }
          }
        },
        "dynamic_templates" => [{
          "property_template" => {
            "mapping" => {
              "type" => "string",
              "index" => "not_analyzed"
            },
            "path_match" => "product.properties.*"
          }
        }]
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
              },
              "untouched" => {
                "type" => "string",
                "index" => "not_analyzed"
              }
            }
          }
        },
        "dynamic_templates" => [{
          "property_template" => {
            "mapping" => {
              "type" => "string",
              "index" => "not_analyzed"
            },
            "path_match" => "product.properties.*"
          }
        }]
      }
    end

    Tire.index "properties" do
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

      mapping :property, {
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
              },
              "untouched" => {
                "type" => "string",
                "index" => "not_analyzed"
              }
            }
          }
        },
      }
    end

    Tire.index "category_property_values" do
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

      mapping :category_property_value, {
        "properties" => {
          "value" => {
            "type" => "multi_field",
            "fields" => {
              "value" => {
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
              },
              "untouched" => {
                "type" => "string",
                "index" => "not_analyzed"
              }
            }
          }
        }
      }
    end

    Tire.index "users" do 
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

      mapping :user, {
        "properties" => {
          "login" => {
            "type" => "multi_field",
            "fields" => {
              "login" => {
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
              },
              "untouched" => {
                "type" => "string",
                "index" => "not_analyzed"
              }
            }
          },
          "address" => {
            "type" => "multi_field",
            "fields" => {
              "primitive" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "indexAnalyzer" => "mmseg",
                "searchAnalyzer" => "mmseg",
                "include_in_all" => "true",
                "boost" => 10
              },
              "untouched" => {
                "type" => "string",
                "index" => "not_analyzed"
              }
            }
          }
        }
      }
    end

    Tire.index "shops" do 
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

      mapping :shop, {
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
              },
              "untouched" => {
                "type" => "string",
                "index" => "not_analyzed"
              }
            }
          },
          "shop_summary" => {
            "type" => "multi_field",
            "fields" => {
              "primitive" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "indexAnalyzer" => "mmseg",
                "searchAnalyzer" => "mmseg",
                "include_in_all" => "true",
                "boost" => 10
              },
              "untouched" => {
                "type" => "string",
                "index" => "not_analyzed"
              }
            }
          },
          "address" => {
            "type" => "multi_field",
            "fields" => {
              "primitive" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "indexAnalyzer" => "mmseg",
                "searchAnalyzer" => "mmseg",
                "include_in_all" => "true",
                "boost" => 10
              },
              "untouched" => {
                "type" => "string",
                "index" => "not_analyzed"
              }
            }
          }
        }
      }
    end

    Tire.index "circles" do 
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

      mapping :circle, {
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
              },
              "untouched" => {
                "type" => "string",
                "index" => "not_analyzed"
              }
            }
          },
          "description" => {
            "type" => "multi_field",
            "fields" => {
              "primitive" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "indexAnalyzer" => "mmseg",
                "searchAnalyzer" => "mmseg",
                "include_in_all" => "true",
                "boost" => 10
              },
              "untouched" => {
                "type" => "string",
                "index" => "not_analyzed"
              }
            }
          },
          "address" => {
            "type" => "multi_field",
            "fields" => {
              "primitive" => {
                "type" => "string",
                "store" => "no",
                "term_vector" => "with_positions_offsets",
                "indexAnalyzer" => "mmseg",
                "searchAnalyzer" => "mmseg",
                "include_in_all" => "true",
                "boost" => 10
              },
              "untouched" => {
                "type" => "string",
                "index" => "not_analyzed"
              }
            }
          }
        }
      }
    end
  end

  desc "load index model data"
  task :data_load => :environment do
    [Product, ShopProduct, Activity,User,Circle, Shop, AskBuy, Property, CategoryPropertyValue].each do |klass|
      total = klass.count
      index = klass.tire.index
      Tire::Tasks::Import.add_pagination_to_klass(klass)
      Tire::Tasks::Import.progress_bar(klass, total) if total
      Tire::Tasks::Import.create_index(index, klass)
      Tire::Tasks::Import.import_model(index, klass, {})
    end
  end
end

