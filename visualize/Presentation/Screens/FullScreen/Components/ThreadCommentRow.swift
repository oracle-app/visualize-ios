//
//  ThreadCommentRow.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/28/26.
//
import SwiftUI
import FirebaseCore

struct ThreadCommentRow: View {
    var comment: Comment
    var image: UIImage? = nil
    
    @Binding var activeCommentID: String?
    var isReplying: Bool { activeCommentID == comment.id }
    
    var body: some View {
        VStack(spacing: 0){
            
            HStack(spacing: 8){
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                
                
                VStack(alignment: .leading, spacing: 2){
                    Text(comment.authorID)
                        .font(.body.weight(.bold))
                        .foregroundStyle(.black)
                    
                    Text("20 min ago")
                        .font(.subheadline)
                        .foregroundStyle(.black.opacity(0.5))
                }
                
                Spacer()
                
                Button{
                    withAnimation(.easeInOut(duration: 0.2)){
                        activeCommentID = isReplying ? nil : comment.id
                    }
                } label: {
                    Image(systemName: "arrowshape.turn.up.left")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 18)
            }
            .background(
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    topTrailingRadius: 20
                )
                .fill(Color.appThreadsPrimary.opacity(0.5))
            )
            
            
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.08))
                    .frame(height: 120)
                    .overlay(
                        Label("", systemImage: "photo")
                            .foregroundStyle(.secondary)
                    )
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
            }
            ThreadRepliesList(threads: comment.threads)
        }
        .background(RoundedRectangle(cornerRadius: 20)
            .fill(Color.appThreadsPrimary.opacity(0.5)))
        .padding(.horizontal, 20)
    }
    
}

private struct ThreadRepliesList: View {
    let threads: [ThreadReply]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(threads) { (reply: ThreadReply) in
                ThreadReplyRow(
                    isFirst: isFirst(reply),
                    reply: reply
                )
            }
        }
    }
    
    private func isFirst(_ reply: ThreadReply) -> Bool {
        threads.first?.id == reply.id
    }
}

#Preview {
    ThreadCommentRow(
        comment: Comment(
            authorID: "Kimberly Marquez",
            content: "Este es un comentario de prueba",
            createdAt: Timestamp(date: Date())
        ),
        activeCommentID: .constant(nil)
    )
}
