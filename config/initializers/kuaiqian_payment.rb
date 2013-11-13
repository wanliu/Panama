require 'openssl'
require 'yaml'

module KuaiQian
  module PayMent

    class << self

      PAYMENT_PARAMS = %w(input_charset page_url bg_url version
        language sign_type merchant_acct_id payer_name
        payer_contact_type payer_contact order_id order_amount
        order_time product_name product_num product_id product_desc
        pay_type bank_id redo_flag pid ext1 ext2).map(&:to_sym)

      def request(options)
        Request.new(options)
      end

      def response
      end

      def config
        @config ||= YAML::load_file("config/kuaiqian_payment.yml").symbolize_keys
        @config
      end

      private

      class Options < Struct.new(*PAYMENT_PARAMS)

        def initialize(opts)
          opts.each{|k, v| send("#{k}=", v) }
          default
        end

        def attributes
          PAYMENT_PARAMS.inject({}){|h, key| h[key]=send(key); h }
        end

        def default
          self.order_time ||= DateTime.now.strftime("%Y%m%d%H%M%S")
          self.input_charset ||= "1"
          self.language ||= "1"
          self.pay_type ||= "00"
          self.redo_flag ||= "0"
          self.sign_type ||= "4"
        end
      end

      class Request

        def initialize(opts = {})
          opts = opts.symbolize_keys!.slice!(params)
          opts.merge!(config[:params].symbolize_keys)
          @options = Options.new(opts)
          @options.order_amount = 1 unless config[:environment] == "production"
        end

        def openssl_sign
          pri = OpenSSL::PKey::RSA.new(File.read(config[:rsa]["path"]), config[:rsa]["password"])
          sign = pri.sign(OpenSSL::Digest::SHA1.new, to_param.gsub(/\s/, ''))
          Base64.encode64(sign).gsub(/\n/, '')
        end

        def md5_sign
          Digest::MD5.hexdigest(to_param)
        end

        def config
          KuaiQian::PayMent.config
        end

        def to_param
          @options.attributes.map do |k, v|
            v.blank? ? nil : "#{k.to_s.camelize(:lower)}=#{v}"
          end.compact.join("&")
        end

        def url
          "#{config[:remote]}?#{to_param}&signMsg=#{sign_msg}"
        end

        private
        def params
          %w(bg_url page_url payer_name
            payer_contact_type payer_contact
            order_id order_amount order_time
            product_name product_num product_id
            product_desc ext1 ext2 pay_type bank_id
          ).map(&:to_sym)
        end

        def sign_msg
          case @options.sign_type.to_s
          when "4"
            openssl_sign
          when "1"
            md5_sign
          end
        end
      end

    end
  end
end
