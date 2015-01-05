//
//  DeckPieChartViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 12/30/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class PieChartViewController: UIViewController, CPTPlotDataSource {

    var graphTitle:String?
    var conciseData:Array<Dictionary<String, Int>>?
    var detailedData:Array<Dictionary<String, Int>>?
    var conciseColors: Array<String>?
    var detailedColors: Array<String>?
    
    var detailsEnabled = false
    var detailsButton:UIBarButtonItem?
    var hostView:CPTGraphHostingView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        detailsButton = UIBarButtonItem(image: UIImage(named: "zoom_in.png"),
                                        style: UIBarButtonItemStyle.Plain,
                                        target: self,
                                        action: "detailsButtonTapped")
        
        self.navigationItem.rightBarButtonItem = detailsButton

        self.configureHost()
        self.configureGraph()
        self.configureChart()
        self.configureLegend()
        
#if !DEBUG
        // send the screen to Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: self.navigationItem.title)
        tracker.send(GAIDictionaryBuilder.createScreenView().build())
#endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func detailsButtonTapped() {
        detailsEnabled = !detailsEnabled
        detailsButton!.image = detailsEnabled ? UIImage(named: "zoom_out.png") : UIImage(named: "zoom_in.png")
        
        self.hostView!.hostedGraph.reloadData()
    }
    
    func configureHost() {
        var parentRect = self.view.bounds
        self.hostView = CPTGraphHostingView(frame: parentRect)
        self.hostView!.allowPinchScaling = false
        self.view.addSubview(self.hostView!)
    }
    
    func configureGraph() {
        // 1 - Create and initialize graph
        let graph = CPTXYGraph(frame: self.hostView!.bounds)
        self.hostView!.hostedGraph = graph
        graph.paddingLeft   = 0.0
        graph.paddingTop    = 0.0
        graph.paddingRight  = 0.0
        graph.paddingBottom = 0.0
        graph.axisSet = nil
        
        // 2 - Set up text style
        let textStyle = CPTMutableTextStyle.textStyle() as CPTMutableTextStyle
        textStyle.color = CPTColor.grayColor()
        textStyle.fontName = "Helvetica-Bold"
        textStyle.fontSize = 16.0

        // 3 - Configure title
        graph.title = graphTitle
        graph.titleTextStyle = textStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop
        graph.titleDisplacement = CGPoint(x:0, y:-80)
        
        graph.applyTheme(CPTTheme(named: kCPTPlainWhiteTheme))
        graph.plotAreaFrame.borderLineStyle = nil
    }
    
    func configureChart() {
        // 1 - Get reference to graph
        let graph = self.hostView!.hostedGraph
        
        // 2 - Create chart
        let pieChart = CPTPieChart()
        pieChart.dataSource = self
        pieChart.delegate = self
        pieChart.pieRadius = (self.hostView!.bounds.size.width * 0.7) / 2
        pieChart.identifier = graph.title
        pieChart.startAngle = CGFloat(M_PI_4)
        pieChart.sliceDirection = CPTPieDirectionClockwise
        
        // 3 - Create gradient
        var overlayGradient = CPTGradient()
        overlayGradient.gradientType = CPTGradientTypeRadial
        overlayGradient = overlayGradient.addColorStop(CPTColor.blackColor().colorWithAlphaComponent(0.0), atPosition: 0.9)
        overlayGradient = overlayGradient.addColorStop(CPTColor.blackColor().colorWithAlphaComponent(0.4), atPosition: 1.0)
        pieChart.overlayFill = CPTFill(gradient: overlayGradient)
        
        // 4 - Add chart to graph
        graph.addPlot(pieChart)
    }
    
    func configureLegend() {
        // 1 - Get graph instance
        let graph = self.hostView!.hostedGraph
        
        // 2 - Create legend
        let theLegend = CPTLegend(graph: graph)
        
        // 3 - Configure legend
        theLegend.numberOfColumns = 1;
        theLegend.fill = CPTFill(color: CPTColor.whiteColor())
        theLegend.borderLineStyle = CPTLineStyle()
        theLegend.cornerRadius = 5.0
        
        // 4 - Add legend to graph
        graph.legend = theLegend
        graph.legendAnchor = CPTRectAnchorBottomRight
//        let legendPadding = -(self.view.bounds.size.width / 8)
        graph.legendDisplacement = CGPoint(x: 0, y: 0)
    }

    // CPTPlotDataSource methods
    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        
        return detailsEnabled ? UInt(detailedData!.count) : UInt(conciseData!.count)
    }
    
    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex index: UInt) -> NSNumber {
        let dict = detailsEnabled ? detailedData![Int(index)] : conciseData![Int(index)]
        let keys = dict.keys
        let part = Double(dict[keys.first!]!)
        
        // compute the totalCount
        let data = detailsEnabled ? detailedData : conciseData
        var totalCount = 0
        for d in data! {
            let ks = d.keys
            totalCount += Int(d[ks.first!]!)
        }
        
        return (part / Double(totalCount))*100
    }
    
    func dataLabelForPlot(plot: CPTPlot, recordIndex index: UInt) -> CPTLayer {
        var labelText: CPTMutableTextStyle?
        
        if labelText == nil {
            labelText = CPTMutableTextStyle()
            labelText!.color = CPTColor.grayColor()
        }

        let formatter =  NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = NSNumberFormatterRoundingMode.RoundCeiling
        formatter.numberStyle = NSNumberFormatterStyle.PercentStyle
        
        let dict = detailsEnabled ? detailedData![Int(index)] : conciseData![Int(index)]
        let keys = dict.keys
        let part = Double(dict[keys.first!]!)
        
        // compute the totalCount
        let data = detailsEnabled ? detailedData : conciseData
        var totalCount = 0
        for d in data! {
            let ks = d.keys
            totalCount += Int(d[ks.first!]!)
        }
        
        let label = formatter.stringFromNumber(part/Double(totalCount))
        
        return CPTTextLayer(text: label, style: labelText)
    }
    
    // CPTPieChartDataSource
    func legendTitleForPieChart(pieChart: CPTPieChart, recordIndex index: UInt) -> String {
        let dict = detailsEnabled ? detailedData![Int(index)] : conciseData![Int(index)]
        let keys = dict.keys
        let part = dict[keys.first!]
        
        return "\(keys.first!): \(part!)x"
    }
    
    func sliceFillForPieChart(pieChart: CPTPieChart, recordIndex idx: UInt) -> CPTFill {
        var fill:CPTFill?
        var colors = detailsEnabled ? detailedColors : conciseColors
        
        if colors != nil {
            let color = colors![Int(idx)]
            
            if color == "Black" {
                return CPTFill(color: CPTColor.blackColor())
            } else if color == "Blue" {
                return CPTFill(color: CPTColor.blueColor())
            } else if color == "Red" {
                return CPTFill(color: CPTColor.redColor())
            } else if color == "Green" {
                return CPTFill(color: CPTColor.greenColor())
            } else if color == "White" {
                return CPTFill(color: CPTColor.whiteColor())
            } else if color == "Gold" {
                return CPTFill(color: CPTColor.yellowColor())
            } else if color == "Colorless" {
                return CPTFill(color: CPTColor.grayColor())
            }
        }
        
        return CPTFill(color: CPTPieChart.defaultPieSliceColorForIndex(idx))
    }
}
