import UIKit


import QuartzCore


protocol ChannelProtocol{
    //回调函数 将详细页的id传回去
    func onChangeChannel(channel_id:String)
}

class ChannelController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tv: UITableView!
    
    
    var channelData:NSArray = NSArray()
    var delegate:ChannelProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "channel")
        let rowData:NSDictionary = self.channelData[indexPath.row] as!NSDictionary
        cell.textLabel?.text = rowData["name"] as? String
        
        return cell
    }
    
    
    //点击单元格返回到上一个view
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var rowData:NSDictionary = self.channelData[indexPath.row] as! NSDictionary
//        let channel_id:AnyObject = rowData["channel_id"] as AnyObject
//        let channel_id:String = "channel=\(channel_id)"
        
        let channel_id:AnyObject=rowData["channel_id"] as AnyObject!
        let channel:String="channel=\(channel_id)"
        delegate?.onChangeChannel(channel)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //单元格的特效
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    
}