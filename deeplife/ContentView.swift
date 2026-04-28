//
//  ContentView.swift
//  deeplife
//
//  Created by Tharindu Epasingha on 2026-04-28.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.name) private var projects: [Project]
    @State private var showingAddSheet = false
    @State private var projectToDelete: Project?

    let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Deep Life")
                            .font(.largeTitle.bold())
                        weekRangeLabel
                    }
                    Spacer()
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .buttonStyle(.plain)

                }
                .padding(.horizontal)

                if projects.isEmpty {
                    VStack(spacing: 12) {
                        Text("No projects yet")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("Tap + to add your first project")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(projects) { project in
                            ProjectCard(
                                project: project,
                                isConfirmingDelete: projectToDelete?.id == project.id,
                                onDeleteTap: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        projectToDelete = project
                                    }
                                },
                                onConfirmDelete: {
                                    withAnimation {
                                        modelContext.delete(project)
                                    }
                                    projectToDelete = nil
                                },
                                onCancelDelete: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        projectToDelete = nil
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .frame(minWidth: 420, minHeight: 480)
        .onAppear {
            for project in projects {
                project.resetIfNewWeek()
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddProjectSheet()
        }
    }

    private var weekRangeLabel: some View {
        let monday = Project.currentWeekMonday()
        let sunday = Calendar.current.date(byAdding: .day, value: 6, to: monday)!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: monday)
        let end = formatter.string(from: sunday)
        return Text("Week of \(start) – \(end)")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

// MARK: - Project Card

struct ProjectCard: View {
    @Bindable var project: Project
    var isConfirmingDelete: Bool = false
    var onDeleteTap: () -> Void = {}
    var onConfirmDelete: () -> Void = {}
    var onCancelDelete: () -> Void = {}

    var body: some View {
        ZStack {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    project.resetIfNewWeek()
                    if project.weeklyCount + 1 <= project.weeklyTarget {
                        project.weeklyCount += 1
                    }
                }
            } label: {
                VStack(spacing: 10) {
                    Text(project.emoji)
                        .font(.system(size: 36))

                    Text(project.name)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text("\(project.weeklyCount) / \(project.weeklyTarget)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())

                    Text("this week")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 16))
                .overlay {
                    ProgressBorder(progress: project.progress)
                }
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button(role: .destructive) {
                    onDeleteTap()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }

            if isConfirmingDelete {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)

                VStack(spacing: 12) {
                    Text("Delete \"\(project.name)\"?")
                        .font(.subheadline.bold())
                        .multilineTextAlignment(.center)

                    HStack(spacing: 8) {
                        Button("Cancel") {
                            onCancelDelete()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                        Button("Delete") {
                            onConfirmDelete()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .controlSize(.small)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Animated Progress Border

struct ProgressBorder: View {
    var progress: Double

    private var progressColor: Color {
        if progress >= 1.0 { return .green }
        if progress >= 0.5 { return .orange }
        return .blue
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.quaternary, lineWidth: 3)

            RoundedRectangle(cornerRadius: 16)
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: progress)
        }
    }
}

// MARK: - Add Project Sheet

struct AddProjectSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var emoji = "📌"
    @State private var weeklyTarget = 3

    let emojiOptions = [
        "🏋️", "🏃", "☁️", "🏗️", "⎈", "🌱", "📚", "💻", "🎸", "🧘",
        "✍️", "🎨", "🧪", "📐", "🔧", "🗣️", "🏊", "🚴", "🧠", "📌"
    ]

    var body: some View {
        VStack(spacing: 24) {
            Text("New Project")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 8) {
                Text("Emoji")
                    .font(.subheadline.bold())
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 8) {
                    ForEach(emojiOptions, id: \.self) { option in
                        Text(option)
                            .font(.title2)
                            .frame(width: 40, height: 40)
                            .background(
                                emoji == option ? Color.accentColor.opacity(0.2) : Color.clear,
                                in: RoundedRectangle(cornerRadius: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(emoji == option ? Color.accentColor : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture { emoji = option }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.subheadline.bold())
                TextField("e.g. Gym, AWS Cert, Gardening", text: $name)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Weekly Target")
                    .font(.subheadline.bold())
                HStack {
                    Text("\(weeklyTarget)")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .frame(width: 40)
                    Stepper("", value: $weeklyTarget, in: 1...21)
                        .labelsHidden()
                    Spacer()
                }
            }

            Spacer()

            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Add Project") {
                    let project = Project(name: name, emoji: emoji, weeklyTarget: weeklyTarget)
                    modelContext.insert(project)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 360, height: 440)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, configurations: config)

    let sampleProjects = [
        Project(name: "Gym", emoji: "🏋️", weeklyTarget: 5, weeklyCount: 3),
        Project(name: "Running", emoji: "🏃", weeklyTarget: 4, weeklyCount: 2),
        Project(name: "AWS Cert", emoji: "☁️", weeklyTarget: 3, weeklyCount: 1),
        Project(name: "Terraform", emoji: "🏗️", weeklyTarget: 3, weeklyCount: 0),
        Project(name: "Kubernetes", emoji: "⎈", weeklyTarget: 4, weeklyCount: 4),
        Project(name: "Gardening", emoji: "🌱", weeklyTarget: 2, weeklyCount: 1),
    ]
    for p in sampleProjects {
        container.mainContext.insert(p)
    }

    return ContentView()
        .modelContainer(container)
}
