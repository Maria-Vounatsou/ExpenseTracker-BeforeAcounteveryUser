//
//  ExpenseDetailView.swift
//  ExperimentApp
//
//  Created by Vounatsou, Maria on 6/9/24.
//

import Foundation
import SwiftUI

struct DetailView: View {
    @ObservedObject var viewModel: DetailViewModel
        var categoryName: String

        var body: some View {
            List {
                ForEach(viewModel.expenses, id: \.id) { expense in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(expense.expenseDescription ?? "No description")
                                .font(.headline)
                            Text("Amount: \(expense.amount, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(viewModel.formatDate(expense.date))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete(perform: viewModel.deleteExpenseFromDetail)

                // Display the total amount at the end of the list
                Section() {
                    Text("Total Amount: \(viewModel.totalAmount, specifier: "%.2f")")
                        .font(.headline)
                }
            }
            .navigationTitle(categoryName)
        }
    }
