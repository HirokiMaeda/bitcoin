require 'net/http'
require 'uri'
require 'json'
require "openssl"
require './key'

def get_price
  '''
  ビットコインの現在の価格を取得するメソッド
  '''
  uri = URI.parse("https://api.bitflyer.com")
  uri.path = '/v1/getboard'
  uri.query = ''

  '''
  uri.query : どの取引のデータを取得するか

  bitFlyer Lightningで扱っている取引

  BTC/JPY : ビットコインと円の取引
  BTC-FX/JPY : ビットコインの値段の変動を予測して行なう FX
  ETH/BTC イーサリアムとビットコインの取引
  '''

  #HTTP通信の設定
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  #ビットコイン取引データを json 形式で取得
  response = https.get uri.request_uri
  # puts response.body

  # jsonデータをハッシュに変換
  response_hash = JSON.parse(response.body)

  #現在の値段 mid_price (売りに出されているものの最小価格と買われている値段の最大価格の中間値) の取得 API参照
  puts response_hash["mid_price"]
end

def order(side, price, size)
  '''
  bitcoin を売買するメソッド
  side = BUY or SELL
  '''

  key = API_KEY
  secret = API_SECRET

  timestamp = Time.now.to_i.to_s
  method = "POST"
  uri = URI.parse("https://api.bitflyer.com")
  uri.path = "/v1/me/sendchildorder"

  # 注文設定
  body = '{
    "product_code": "BTC_JPY",
    "child_order_type": "LIMIT",
    "side": "' + side + '" ,
    "price":' + price + ',
    "size":' + size + ',
    "minute_to_expire": 10000, #注文が無効になる時間(分)
    "time_in_force": "GTC"
  }'

  text = timestamp + method + uri.request_uri + body
  sign = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret, text)

  options = Net::HTTP::Post.new(uri.request_uri, initheader = {
   "ACCESS-KEY" => key,
   "ACCESS-TIMESTAMP" => timestamp,
   "ACCESS-SIGN" => sign,
   "Content-Type" => "application/json"
  });
  options.body = body

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  response = https.request(options)
  puts response.body
end


def get_my_money(coin_name)
  '''
  自分が現在持っている資産の表示
  coin_name = JPY, BTC etc.
  '''
  key = API_KEY
  secret = API_SECRET

  timestamp = Time.now.to_i.to_s
  method = "GET"
  uri = URI.parse("https://api.bitflyer.com")
  uri.path = "/v1/me/getbalance"


  text = timestamp + method + uri.request_uri
  sign = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret, text)

  options = Net::HTTP::Get.new(uri.request_uri, initheader = {
   "ACCESS-KEY" => key,
   "ACCESS-TIMESTAMP" => timestamp,
   "ACCESS-SIGN" => sign,
  });

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  response = https.request(options)
  response_hash = JSON.parse(response.body)
  puts response_hash.find {|n| n["currency_code"] == coin_name }
end

def ifdoneOCO
  key = API_KEY
  secret = API_SECRET

  timestamp = Time.now.to_i.to_s
  method = "POST"
  uri = URI.parse("https://api.bitflyer.com")
  uri.path = "/v1/me/sendparentorder"
  body = {
  "order_method": "IFDOCO",
  "minute_to_expire": 10000,
  "time_in_force": "GTC",
  "parameters": [{
    "product_code": "BTC_JPY",
    "condition_type": "LIMIT",
    "side": "BUY",
    "price": 450000,
    "size": 0.001
  },
  {
    "product_code": "BTC_JPY",
    "condition_type": "LIMIT",
    "side": "SELL",
    "price": 460000,
    "size": 0.001
  },
  {
    "product_code": "BTC_JPY",
    "condition_type": "STOP_LIMIT",
    "side": "SELL",
    "price": 440000,
    "trigger_price": 29000,
    "size": 0.001
  }]
}


  text = timestamp + method + uri.request_uri + body
  sign = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret, text)

  options = Net::HTTP::Post.new(uri.request_uri, initheader = {
    "ACCESS-KEY" => key,
    "ACCESS-TIMESTAMP" => timestamp,
    "ACCESS-SIGN" => sign,
    "Content-Type" => "application/json"
  });
  options.body = body

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  response = https.request(options)
  puts response.body
end
