//
//  BarChartWrapper.swift
//  ExperimentApp
//
//  Created by Vounatsou, Maria on 6/9/24.
//
//
import SwiftUI
import DGCharts

struct PieChartWrapper: UIViewRepresentable {
    @ObservedObject var viewModel: PieChartViewModel
    
    func makeUIView(context: Context) -> PieChartView {
        PieChartView()
    }
    
    func updateUIView(_ uiView: PieChartView, context: Context) {
        let dataSet = PieChartDataSet(entries: viewModel.pieChartDataEntries)
        dataSet.colors = ChartColorTemplates.pastel() // Use a predefined color template
        
        // Disable drawing entry labels (category names)
        uiView.drawEntryLabelsEnabled = false
        
        // Setup the formatter for percentages
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        formatter.percentSymbol = "%"
        
        let data = PieChartData(dataSet: dataSet)
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        data.setValueTextColor(.white)
        data.setValueFont(.boldSystemFont(ofSize: 16))
        
        uiView.data = data
        uiView.usePercentValuesEnabled = true
        
        // Calculate total amount and set it as center text
        uiView.centerText = viewModel.calculateTotalAmount()
        
        uiView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
        
        // Customize the legend
        let legend = uiView.legend
        legend.textColor = .white
        legend.font = UIFont.systemFont(ofSize: 12)
    }
    typealias UIViewType = PieChartView
}

