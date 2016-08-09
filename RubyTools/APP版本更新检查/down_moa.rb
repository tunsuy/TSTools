require "net/http"  
  
class Fetcher  
   
 def fetch(url)  
   host = url.scan(/\/\/(.*?)\//m)[0][0]  
   path = url.split(/#{host}\//)[1]  
  # print "host: ",host,"\n"  
  # print "path: ",path,"\n"  
   h = Net::HTTP.new(host,80)  
   resp = h.get("/#{path}",nil)  
    
   if resp.message == "OK"  
    # puts "建立连接成功..."   
     return resp.body       
   end   
   return ""  
 end
end  


class Parser  
public  
  def initialize()  
    @fetcher = Fetcher.new  
  end  
  
  def parse_mp3(html)  
    urls = html.scan(/<a href="(.*?)"/m)  
    download_hosts_urls = {}  
    parse_threads = []  
    for url in urls do  
        if url[0] =~ /.*?\.mp3,,.*?/  
           parse_threads << Thread.new(url) do |url|  
              song_url = url[0].gsub(" ","%20")  
              download_url = parse_download_url(song_url)  
              if download_url  
                host =  download_url.scan(/\/\/(.*?)\//m)[0][0]   
                #We only want to find the best download url,so we needn't care duplicate key  
                download_hosts_urls[host] = download_url  
              end   
           end  
        end  
    end  
    parse_threads.each{|t| t.join}  
    puts "已经搜索到#{download_hosts_urls.size}个链接可以下载..."  
    exit(1) if download_hosts_urls.size == 0  
    puts "正在选择速度最快的链接..."  
    host = select_best_host(download_hosts_urls.keys)  
    download_hosts_urls[host]  
  end  
  
private  
  def select_best_host(hosts)  
    times_hosts = {}  
    threads = []  
    hosts.each do |host|  
      threads << Thread.new(host) do |host|  
           response = `ping -c 1 -W 30 #{host}` #use`ping -n 1 -w 30 #{host}` in windows  
           r_t = response.scan(/time=(\d+)/m) #only get integer part  
           times_hosts[r_t[0][0]] = host unless r_t.empty? #duplicate key no problem   
      end  
    end  
     
    threads.each{|t| t.join}  
     
    times = times_hosts.keys  
    min = times.min  
    times_hosts[min]  
  end  
  
  def parse_download_url(song_url)  
     html = @fetcher.fetch(song_url)  
     urls = html.scan(/<a href="(.*?)"/m)  
     return nil if urls.empty? || urls[0][0] =~ /.*?\.html/  
     return urls[0][0]        
  end  
end   

require "open-uri"  
require "parser"  
require "fetcher"  
  
class Download  
public  
  def initialize(song_name)  
    @song_name = song_name  
    @search_url = "http://200.200.107.38/"  
    @parser = Parser.new  
    @fetcher = Fetcher.new  
  end  
   
  def download  
    puts "正在建立连接..."  
    html = @fetcher.fetch(@search_url)  
    puts "正在获取搜索结果..."  
    url = @parser.parse_mp3(html)  
    puts "已经获得最快的下载连接:#{url}.\n开始下载..."  
    doDownload(url)      
    puts "下载完毕..."  
  end  
private  
  def doDownload(url)  
    open(url) do |fin|  
    size = fin.size  
    download_size = 0  
    puts "大小: #{size / 1024}KB"  
    filename = url[url.rindex('/')+1, url.length-1]  
    puts "歌曲名: #{filename}"  
    open(File.basename("./#{filename}"),"wb") do |fout|  
            while buf = fin.read(1024) do  
            fout.write buf  
            download_size += buf.size  
                print "已经下载： #{download_size * 100 / size}%\r"  
                STDOUT.flush   
           end  
       end  
    end   
    puts  
  end  
end  
  
download = Download.new(ARGV[0])  
download.download  

def moa_update?
  html = open('http://200.200.107.38/').read(2000000)
  END_CHARS = %{.,'?!:;}
  puts URI.extract(html, ['http']).collect { |u| END_CHARS.index(u[-1]) ? u.chop : u }
end