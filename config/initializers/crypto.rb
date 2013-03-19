# author: huxinghai
# describe: 加密与解密
require "openssl"

module Crypto
    KEY = "panama@gmail.com"
    IV = "WANEW:panama"
    CIPHER = "DES"

    def self.encrypt(en_content)
        unless en_content.blank?
            process(en_content.to_s).unpack("H*")[0]
        end
    end

    def self.decrypt(de_content)
        unless de_content.blank?
            process([de_content].pack("H*"),false)
        end
    end

    private
    def self.process(content,is_encode=true)
        c = OpenSSL::Cipher::Cipher.new CIPHER
        c.key = KEY
        c.iv = IV
        is_encode ? c.encrypt : c.decrypt
        ret = c.update(content)

        ret << c.final
    end
end