require 'tire'

namespace "index" do
  desc "import pinyin index"
  task :load => :environment do 
    Tire.index "products" do 
      delete

      setup({})
      
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
                        "first_letter" => "prefix",
                        "padding_char" => ""
                    }
                }
            }
        }
        # "index" => {
        #     "analysis" => {
        #         "analyzer" => {
        #             "pinyin_analyzer" => {
        #                 "tokenizer" => ["my_pinyin"],
        #                 "filter" => ["standard","nGram"]
        #             }
        #         },
        #         "tokenizer" => {
        #             "my_pinyin" => {
        #                 "type" => "pinyin",
        #                 "first_letter" => "prefix",
        #                 "padding_char" => ""
        #             }
        #         }
        #     }
        # }
      })
    end
  end
end
