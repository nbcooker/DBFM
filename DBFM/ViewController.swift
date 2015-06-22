
import UIKit

import MediaPlayer

import QuartzCore

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,HttpProtocol,ChannelProtocol {

    @IBOutlet weak var tv: UITableView!
    
    @IBOutlet weak var iv: UIImageView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    
    @IBOutlet weak var playTim: UILabel!
    
    var eHttp:HttpController = HttpController()
    
    var tableData:NSArray = NSArray()
    
    var channelData:NSArray = NSArray()
    
    var imageCache = Dictionary<String,UIImage>()
    
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()
    
    var timer:NSTimer?
    @IBOutlet var tap: UITapGestureRecognizer!
    
    @IBOutlet weak var btnPlay: UIImageView!
    
    
    //响应点击tap的一个动作的方法
    
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        //println("tap")
        if sender.view==btnPlay {
            btnPlay.hidden=true
            audioPlayer.play()
            btnPlay.removeGestureRecognizer(tap)
            iv.addGestureRecognizer(tap)
        }else if sender.view==iv {
            btnPlay.hidden=false
            audioPlayer.pause()
            btnPlay.addGestureRecognizer(tap)
            iv.removeGestureRecognizer(tap)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eHttp.delegate=self
        eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
        eHttp.onSearch("http://douban.fm/j/mine/playlist?channel=0")
        //进度条设置为0
        progressView.progress = 0.0
        //iv.addGestureRecognizer(tap!)
        iv.addGestureRecognizer(tap)
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        eHttp.delegate=self
//        eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
//        eHttp.onSearch("http://douban.fm/j/mine/playlist?channel=0")
//    }


    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "douban")
        let rowData:NSDictionary = self.tableData[indexPath.row] as! NSDictionary
        //println(rowData)
        cell.textLabel?.text = rowData["title"] as? String
        cell.detailTextLabel?.text = rowData["artist"] as? String
        cell.imageView?.image = UIImage(named:"detail.jpg")
        let url = rowData["picture"] as! String
        //let image = self.imageCache[url] as?UIImage
        let image = self.imageCache[url]
        if (image == nil){
            let imgURL:NSURL=NSURL(string:url)!
            let request:NSURLRequest=NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response:NSURLResponse!,data:NSData!,error:NSError!)->Void in
                var img=UIImage(data:data)
                cell.imageView?.image=img
                self.imageCache[url]=img
            })
        }else{
            cell.imageView?.image=image
        }
        return cell
    }
    
    func didRecieveResults(results:NSDictionary) {
        if (results["song"] != nil) {
            self.tableData = results["song"] as! NSArray
            //println(self.tableData)
            self.tv.reloadData()
            
            let firDict:NSDictionary = self.tableData[0] as! NSDictionary
            let audioUrl:String = firDict["url"] as! String
            onSetAudio(audioUrl)
            
            let imgUrl:String = firDict["picture"] as! String
            onSetImage(imgUrl)
            
        } else if (results["channels"] != nil){
            self.channelData = results["channels"] as! NSArray
            //self.tv.reloadData()
        }
    }
    
    //播放音乐
    func onSetAudio(url:String) {
        timer?.invalidate()
        playTim.text = "00:00"
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string: url)
        self.audioPlayer.play()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "onUpdate", userInfo: nil, repeats: true)
        btnPlay.removeGestureRecognizer(tap)
        iv.addGestureRecognizer(tap)
        btnPlay.hidden = true
    }
    
    //更新播放时间
    func onUpdate() {
        //返回播放器的当前时间 --- 就是已经播放了多少时间
        let c=audioPlayer.currentPlaybackTime
        if c>0.0 {
            //总时间
            let t=audioPlayer.duration
            let p:CFloat = CFloat(c/t)
            // 设置进度条
            progressView.setProgress(p, animated: true)
            
            //获取总的秒数
            let all:Int = Int(c)
            let m:Int = all % 60
            let f:Int = Int(all/60)
            var time:String = ""
            if f < 10 {
                time="0\(f):"
            } else {
                time="\(f):"
            }
            
            if m < 10 {
                time+="0\(m)"
            } else {
                time+="\(m)"
            }
            
            playTim.text = time
        }
    }
    
    
    //并设置当前音乐图片
    func onSetImage(url:String) {
        
        //let image = self.imageCache[url] as?UIImage
        let image = self.imageCache[url]
        if (image == nil){
            let imgURL:NSURL=NSURL(string:url)!
            let request:NSURLRequest=NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response:NSURLResponse!,data:NSData!,error:NSError!)->Void in
                var img=UIImage(data:data)
                self.iv.image=img
                self.imageCache[url]=img
            })
        }else{
            self.iv.image=image
        }
    }
    
    //点击单元格
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //获取单行数据
        var rowdata:NSDictionary = self.tableData[indexPath.row] as! NSDictionary
        //获取音乐地址
        var audioUrl:String = rowdata["url"] as! String
        onSetAudio(audioUrl)
        //获取图片
        var imgUrl:String = rowdata["picture"] as! String
        onSetImage(imgUrl)
    }
    
    //页面跳转的时候 传递数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var channelC:ChannelController = segue.destinationViewController as! ChannelController
        channelC.delegate = self
        channelC.channelData = self.channelData
    }
    
    
    func onChangeChannel(channel:String) {
        let url:String = "http://douban.fm/j/mine/playlist?\(channel)"
        eHttp.onSearch(url)
    }
    
    //单元格的特效
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
}

