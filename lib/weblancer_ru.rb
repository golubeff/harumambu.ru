class WeblancerRu
  CURRENCIES = { 'USD' => "$" }

  def self.desc
    'weblancer.net'
  end

  def self.latest
    doc = Hpricot(open('http://weblancer.net'))
    args = {}
    resultset = []
    rows = ((doc/'.items_list')/'tr')
    rows.shift
    rows.each do |project_tr|
      args = {}
      cols = project_tr/"td"
      args[:title] = convert(cols.first.at('a').innerText)

      link = cols.first.at('a')
      link = link['href']
      link.gsub!(/[^\d+]/, '')
      args[:remote_id] = link

      args[:url] = "http://weblancer.net/projects/#{link}.html"

      args[:desc] = convert(project_tr.at('.il_item_descr').innerText).gsub(/\|\s*сегодня.*$/, '')
      args[:created_at] = Time.now
      budjet = convert(project_tr.at('.il_medium').innerText)
      if budjet != '?'
        args[:budjet] = budjet.gsub(/[^\d]+/, '').to_f
        args[:currency] = CURRENCIES[budjet.gsub(/^.*\d+\s*/, '')]
      end
      resultset << args
    end
    resultset.reverse
  end

  def self.convert(s)
    Iconv.conv('utf-8', 'windows-1251', s).to_s
  end

end
