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
                        "filter" => ["standard"]
                    }
                },
                "tokenizer" => {
                    "my_pinyin" => {
                        "type" => "pinyin",
                        "first_letter" => "none",
                        "padding_char" => " "
                    }
                }
            }
        }
      })

      close
      put_settings({
        "index" => {
            "analysis" => {
                "analyzer" => {
                    "pinyin_analyzer" => {
                        "tokenizer" => ["my_pinyin"],
                        "filter" => ["standard","nGram"]
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
      open
    end
  end
end
