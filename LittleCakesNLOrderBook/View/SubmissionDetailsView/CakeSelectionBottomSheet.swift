import Foundation
import SwiftUI

enum Language: String, CaseIterable, Identifiable {
  case nl
  case eng

  var id: String { rawValue }
}

enum CakeShape: String, CaseIterable, Identifiable {
  case round = "Round"
  case heart = "Heart"

  var id: String { rawValue }
}


enum CakeSize: String, CaseIterable, Identifiable {
  case oneToFour = "1 - 4"
  case fourToEight = "4 - 8"
  case eightToFifteen = "8 - 15"
  case fifteenToTwenty = "15 - 20"
  case twentyfivePlus = "25+"

  var id: String { rawValue }
}

struct CakePricing {
  static func price(for shape: CakeShape, size: CakeSize) -> Double {
    switch (shape, size) {
    case (.round, .oneToFour): return 40
    case (.round, .fourToEight): return 60
    case (.round, .eightToFifteen): return 75
    case (.round, .fifteenToTwenty): return 95
    case (.round, .twentyfivePlus): return 0

    case (.heart, .oneToFour): return 0
    case (.heart, .fourToEight): return 70
    case (.heart, .eightToFifteen): return 85
    case (.heart, .fifteenToTwenty): return 105
    case (.heart, .twentyfivePlus): return 0
    }
  }
}

struct CakeSelectionBottomSheet: View {
  @Environment(\.dismiss) private var dismiss

  @State private var editedSubmission: MappedSubmission
  @ObservedObject var viewModel: SubmissionsViewModel
  @State private var selectedLanguage: Language? = .nl
  @State private var selectedShape: CakeShape?
  @State private var selectedSize: CakeSize?
  @State private var didCopy = false

  private var canCalculate: Bool {
    selectedShape != nil && selectedSize != nil
  }

  private var priceText: String {
    guard let shape = selectedShape, let size = selectedSize else {
      return "Select shape & size"
    }
    let price = CakePricing.price(for: shape, size: size)
    return "\(shape.rawValue) • \(size.rawValue) • €\(Int(price))"
  }

  init(submission: MappedSubmission, viewModel: SubmissionsViewModel) {
    self.editedSubmission = submission
    self.viewModel = viewModel
  }

  var body: some View {
    VStack(spacing: 20) {

      Text("Select your cake")
        .font(.headline)

      // Language selection
      VStack(alignment: .leading, spacing: 8) {
        Text("Language")
          .font(.subheadline)
          .foregroundStyle(.secondary)

        HStack(spacing: 12) {
          ForEach(Language.allCases) { langauage in
            Button {
              selectedLanguage = langauage
            } label: {
              Text(langauage.rawValue)
                .font(.subheadline)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(
                  selectedLanguage == langauage
                  ? Color.blue.opacity(0.15)
                  : Color(.systemGray6)
                )
                .overlay(
                  RoundedRectangle(cornerRadius: 16)
                    .stroke(selectedLanguage == langauage ? Color.blue : .clear, lineWidth: 1.5)
                )
                .cornerRadius(16)
            }
          }
        }
      }
      // Shape selection
      VStack(alignment: .leading, spacing: 8) {
        Text("Shape")
          .font(.subheadline)
          .foregroundStyle(.secondary)

        HStack(spacing: 12) {
          ForEach(CakeShape.allCases) { shape in
            Button {
              selectedShape = shape
            } label: {
              Text(shape.rawValue)
                .font(.subheadline)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(
                  selectedShape == shape
                  ? Color.blue.opacity(0.15)
                  : Color(.systemGray6)
                )
                .overlay(
                  RoundedRectangle(cornerRadius: 16)
                    .stroke(selectedShape == shape ? Color.blue : .clear, lineWidth: 1.5)
                )
                .cornerRadius(16)
            }
          }
        }
      }

      // Size selection
      VStack(alignment: .leading, spacing: 8) {
        Text("Size")
          .font(.subheadline)
          .foregroundStyle(.secondary)

        // 2x2 grid
        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 12), count: 2), spacing: 12) {
          ForEach(CakeSize.allCases) { size in
            Button {
              selectedSize = size
            } label: {
              Text(size.rawValue)
                .font(.subheadline)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                  selectedSize == size
                  ? Color.blue.opacity(0.15)
                  : Color(.systemGray6)
                )
                .overlay(
                  RoundedRectangle(cornerRadius: 16)
                    .stroke(selectedSize == size ? Color.blue : .clear, lineWidth: 1.5)
                )
                .cornerRadius(16)
            }
          }
        }
      }

      // Price label
      HStack {
        Text("Selection")
          .font(.subheadline)
          .foregroundStyle(.secondary)
        Spacer()
        Text(priceText)
          .fontWeight(.semibold)
          .foregroundStyle(canCalculate ? .primary : .secondary)
      }

      // Copy button
      Button(action: copyToClipboard) {
        Text(didCopy ? "Copied ✅" : "Copy to clipboard")
          .font(.headline)
          .frame(maxWidth: .infinity)
          .padding()
          .background(canCalculate ? Color.blue : Color.gray.opacity(0.4))
          .foregroundColor(.white)
          .cornerRadius(18)
      }
      .disabled(!canCalculate)
      .padding(.bottom, 16)
    }
    .padding(.horizontal, 20)
    .onAppear {
      selectedSize = viewModel.getSubmissionSize(editedSubmission)
      selectedShape = viewModel.getSubmissionShape(editedSubmission)
    }
  }

  private func copyToClipboard() {
    guard canCalculate,
          let shape = selectedShape,
          let size = selectedSize
    else { return }

    let price = CakePricing.price(for: shape, size: size)
    let text = "\(shape.rawValue) \(size.rawValue) - €\(Int(price))"

    #if os(iOS)

    UIPasteboard.general.string = viewModel.getConfirmationMessageCopy(editedSubmission, totalPrice: price, isEnglish: selectedLanguage == .eng)
    UINotificationFeedbackGenerator().notificationOccurred(.success)
    #endif

    withAnimation {
      didCopy = true
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      withAnimation {
        didCopy = false
      }
    }
  }
}
