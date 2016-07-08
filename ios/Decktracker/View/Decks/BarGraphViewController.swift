//
//  BarGraphViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 12/31/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class BarGraphViewController: UIViewController, CPTBarPlotDataSource {

    var graphTitle:String?
    
    var hostView:CPTGraphHostingView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initPlot()
        
#if !DEBUG
        // send the screen to Google Analytics
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: self.navigationItem.title)
            tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        }
#endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func initPlot() {
        let parentRect = self.view.bounds
        self.hostView = CPTGraphHostingView(frame: parentRect)
        self.hostView!.allowPinchScaling = false
        self.view.addSubview(self.hostView!)
        
        self.configureGraph()
        self.configurePlots()
        self.configureAxes()
    }
    
    func configureGraph() {
        // 1 - Create the graph
        let graph = CPTXYGraph(frame: self.hostView!.bounds)
        graph.plotAreaFrame!.masksToBorder = false
        self.hostView!.hostedGraph = graph;
        
        // 2 - Configure the graph
        graph.applyTheme(CPTTheme(named: kCPTPlainWhiteTheme))
        graph.paddingBottom = 45
        graph.paddingLeft   = 45
        graph.paddingTop    = -5.0
        graph.paddingRight  = -5.0
        
        // 3 - Set up styles
        let titleStyle = CPTMutableTextStyle() //.textStyle() as CPTMutableTextStyle
        titleStyle.color = CPTColor.grayColor()
        titleStyle.fontName = "Helvetica-Bold"
        titleStyle.fontSize = 16.0
        
        // 4 - Set up title
        graph.title = graphTitle
        graph.titleTextStyle = titleStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchor.Top
        graph.titleDisplacement = CGPoint(x:0, y:-80)
        
        // 5 - Set up plot space
//        let xMin = 0
//        let xMax = 10
//        let yMin = 0
//        let yMax = 20
//        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
//        var xRange = plotSpace.xRange.mutableCopy() as CPTMutablePlotRange
//        var yRange = plotSpace.yRange.mutableCopy() as CPTMutablePlotRange
//        xRange.setLengthFloat(10)
//        yRange.setLengthFloat(10)
//        plotSpace.xRange = xRange
//        plotSpace.yRange = yRange
        
//        let xRange = CPTPlotRange()
//        plotSpace.xRange = xRange
//        plotSpace.yRange = CPTPlotRange()
//
//        plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
    }
    
    func configurePlots() {
        // 1 - Set up the three plots
        let plot1 = CPTBarPlot.tubularBarPlotWithColor(CPTColor.redColor(), horizontalBars:false)
        plot1.identifier = "high"
        
        let plot2 = CPTBarPlot.tubularBarPlotWithColor(CPTColor.redColor(), horizontalBars:false)
        plot2.identifier = "high"
        
        // 2 - Set up line style
        let barLineStyle = CPTMutableLineStyle()
        barLineStyle.lineColor = CPTColor.blackColor()
        barLineStyle.lineWidth = 0.5
        
        // 3 - Add plots to graph
        let graph = self.hostView!.hostedGraph
        let plots = [plot1, plot2]
        var barX = CGFloat(0.25)
        for plot in plots {
            plot.dataSource = self;
            plot.delegate = self;
//            MARK: 
//            MARK: what to do here???
//            plot.barWidthScale = 0.25
//            plot.barOffsetScale = barX
//            MARK: 
            plot.lineStyle = barLineStyle
            graph!.addPlot(plot, toPlotSpace: graph!.defaultPlotSpace)
            barX += 0.25
        }
    }
    
    func configureAxes() {
        // 1 - Configure styles
        let axisTitleStyle = CPTMutableTextStyle() //.textStyle() as! CPTMutableTextStyle
        axisTitleStyle.color = CPTColor.blackColor()
        axisTitleStyle.fontName = "Helvetica-Bold"
        axisTitleStyle.fontSize = 12
        let axisLineStyle = CPTMutableLineStyle()//.lineStyle() as! CPTMutableLineStyle
        axisLineStyle.lineWidth = 2
        axisLineStyle.lineColor = CPTColor.blackColor().colorWithAlphaComponent(1)
        
        // 2 - Get the graph's axis set
        let axisSet = self.hostView!.hostedGraph!.axisSet as! CPTXYAxisSet
        
        // 3 - Configure the x-axis
//        axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyFixedInterval
        axisSet.xAxis!.title = "Converted Mana Cost"
        axisSet.xAxis!.titleTextStyle = axisTitleStyle
        axisSet.xAxis!.titleOffset = 25
        axisSet.xAxis!.axisLineStyle = axisLineStyle
        
        // 4 - Configure the y-axis
//        axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone
        axisSet.yAxis!.title = "Count"
        axisSet.yAxis!.titleTextStyle = axisTitleStyle
        axisSet.yAxis!.titleOffset = 25
        axisSet.yAxis!.axisLineStyle = axisLineStyle
    }
    
//    MARK: CPTPlotDataSource
    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        return 2
    }
    
    func numberForPlot(plot: CPTPlot, field fieldEnum:UInt, recordIndex index: UInt) -> AnyObject? {
//        if fieldEnum == CPTBarPlotFieldBarTip &&
//        (index < [[[CPDStockPriceStore sharedInstance] datesInWeek] count])) {
//            if ([plot.identifier isEqual:CPDTickerSymbolAAPL]) {
//                return [[[CPDStockPriceStore sharedInstance] weeklyPrices:CPDTickerSymbolAAPL] objectAtIndex:index];
//            } else if ([plot.identifier isEqual:CPDTickerSymbolGOOG]) {
//                return [[[CPDStockPriceStore sharedInstance] weeklyPrices:CPDTickerSymbolGOOG] objectAtIndex:index];
//            } else if ([plot.identifier isEqual:CPDTickerSymbolMSFT]) {
//                return [[[CPDStockPriceStore sharedInstance] weeklyPrices:CPDTickerSymbolMSFT] objectAtIndex:index];
//            }
//        }
        
        if index == 0 {
            return NSDecimalNumber(double: 0.3)
        } else {
            return NSDecimalNumber(double: 0.7)
        }
    }
}
