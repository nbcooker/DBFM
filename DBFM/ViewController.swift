
import UIKit

import MediaPlayer

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eHttp.delegate=self
        eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
        eHttp.onSearch("http://douban.fm/j/mine/playlist?channel=0")
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
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string: url)
        self.audioPlayer.play()
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
}

