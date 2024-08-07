class SpeakerNormalizer
  # NOTE: Conform to the new name
  def self.unify(name)
    case name
    when "SHIBATA Hiroshi"
      "Hiroshi SHIBATA"
    when "TAGOMORI \"moris\" Satoshi", "tagomoris", "Satoshi \"moris\" Tagomori"
      "Satoshi Tagomori"
    when "Thomas E. Enebo"
      "Thomas E Enebo"
    when "Haruka Iwao"
      "Emma Haruka Iwao"
    when "YUKI TORII"
      "Yuki Torii"
    when "Yukihiro Matsumoto", "Yukihiro \"matz\" MATSUMOTO", "まつもとゆきひろ", "Matz"
      "Yukihiro \"Matz\" Matsumoto"
    when "MayumiI EMORI(emorima)"
      "Mayumi EMORI"
    when "Kouhei Sutou"
      "Sutou Kouhei"
    when "moro"
      "Kyosuke MOROHASHI"
    when "Kakutani Shintaro", "KAKUTANI Shintaro"
      "Shintaro Kakutani"
    when "Toshiaki KOSHIBA"
      "Toshiaki Koshiba"
    when "Aaron Patterson (tenderlove)"
      "Aaron Patterson"
    when "Tomoyuki Chikanaga"
      "nagachika"
    when "Akira “akr” Tanaka", "Akira TANAKA", "田中 哲", "田中哲"
      "Tanaka Akira"
    when "SHIGERU NAKAJIMA"
      "Shigeru Nakajima"
    when "Yugui - Yuki Sonoda", "Yugui (Yuki SONODA)"
      "Yugui"
    when "tenderlove"
      "Aaron Patterson"
    when "Shyouhei Urabe", "Urabe Shyouhei"
      "Urabe, Shyouhei"
    when "Koichi SASADA"
      "Koichi Sasada"
    when "Yui NARUSE"
      "NARUSE, Yui"
    when "Charles O. Nutter"
      "Charles Nutter"
    when "Thomas Enebo"
      "Thomas E Enebo"
    when "Akio Tajima aka arton"
      "arton"
    when "Yutaka Hara"
      "Yutaka HARA"
    when "関将俊"
      "Masatoshi SEKI"
    when "高橋征義"
      "Masayoshi Takahashi"
    when "石塚圭樹"
      "Keiju Ishitsuka"
    when "Kentaro GOTO", "後藤謙太郎", "Kentaro Goto", "gotoken"
      "Kentaro Goto / ごとけん"
    when "前田修吾", "Shugo MAEDA"
      "Shugo Maeda"
    when "Daisuke Aritomo"
      "Daisuke Aritomo (osyoyu)"
    else
      name
    end
  end
end
