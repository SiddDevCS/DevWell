import SwiftUI

struct BreakTypeSelectionSheet: View {
    let onSelect: (BreakType) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedType: BreakType? = nil
    @State private var animationComplete = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    
                    breakTypeGrid
                    
                    // Info text
                    Text("Select a break type that best suits your needs right now")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Choose Break Type")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .imageScale(.large)
                        }
                    }
                    
                    ToolbarItem(placement: .bottomBar) {
                        continueButton
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    // MARK: - Views
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 48))
                .foregroundColor(Color.accentColor)
                .padding(.top, 10)
            
            Text("Take a moment for yourself")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 16)
    }
    
    private var breakTypeGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(BreakType.allCases) { breakType in
                BreakTypeCard(
                    breakType: breakType,
                    isSelected: selectedType == breakType,
                    animationComplete: animationComplete
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedType = breakType
                    }
                }
            }
        }
        .padding(.horizontal, 5)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.5)) {
                    animationComplete = true
                }
            }
        }
    }
    
    private var continueButton: some View {
        Button(action: {
            if let selected = selectedType {
                onSelect(selected)
                dismiss()
            }
        }) {
            HStack {
                Spacer()
                Text("Start Break")
                    .fontWeight(.semibold)
                Image(systemName: "arrow.right")
                Spacer()
            }
            .padding()
            .foregroundColor(.white)
            .background(
                selectedType != nil ?
                RoundedRectangle(cornerRadius: 14)
                    .fill(selectedType?.color ?? Color.accentColor) :
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.gray.opacity(0.3))
            )
            .opacity(selectedType != nil ? 1.0 : 0.6)
        }
        .disabled(selectedType == nil)
        .padding(.horizontal)
    }
}

struct BreakTypeCard: View {
    let breakType: BreakType
    let isSelected: Bool
    let animationComplete: Bool
    
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(isSelected ? breakType.color : breakType.color.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: breakType.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : breakType.color)
            }
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            
            // Title
            Text(breakType.rawValue.capitalized)
                .font(.system(size: 16, weight: .semibold))
                .multilineTextAlignment(.center)
            
            // Duration
            Text("\(Int(breakType.recommendedDuration / 60)) min")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: isSelected ? breakType.color.opacity(0.3) : Color.black.opacity(0.05), 
                       radius: isSelected ? 10 : 5,
                       x: 0, y: isSelected ? 4 : 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? breakType.color : Color.clear, lineWidth: isSelected ? 2 : 0)
        )
        .scaleEffect(appear ? 1 : 0.8)
        .opacity(appear ? 1 : 0)
        .onAppear {
            let delay = Double(BreakType.allCases.firstIndex(of: breakType) ?? 0) * 0.1
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                appear = true
            }
        }
    }
}

#Preview {
    BreakTypeSelectionSheet(onSelect: { _ in })
} 