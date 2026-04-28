//
//  MenuBarView.swift
//  deeplife
//
//  Created by Tharindu Epasingha on 2026-04-28.
//

import SwiftUI
import SwiftData

struct MenuBarView: View {
    @Query(sort: \Project.name) private var projects: [Project]
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Deep Life")
                    .font(.headline)
                Spacer()
                Button("Open") {
                    openWindow(id: "main")
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .padding(.horizontal)

            Divider()

            if projects.isEmpty {
                Text("No projects yet")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 2) {
                    ForEach(projects) { project in
                        MenuBarProjectRow(project: project)
                    }
                }
                .padding(.horizontal, 8)
            }

            Divider()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                HStack {
                    Image(systemName: "power")
                    Text("Quit Deep Life")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .padding(.bottom, 4)
        }
        .padding(.vertical, 12)
        .frame(width: 280)
        .onAppear {
            for project in projects {
                project.resetIfNewWeek()
            }
        }
    }
}

struct MenuBarProjectRow: View {
    var project: Project

    var body: some View {
        HStack(spacing: 10) {
            Text(project.emoji)
                .font(.title3)

            Text(project.name)
                .font(.subheadline)
                .lineLimit(1)

            Spacer()

            Text("\(project.weeklyCount)/\(project.weeklyTarget)")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(project.progress >= 1.0 ? .green : .primary)

            progressCircle
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(.quaternary.opacity(0.01), in: RoundedRectangle(cornerRadius: 8))
    }

    private var progressCircle: some View {
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: 3)
            Circle()
                .trim(from: 0, to: CGFloat(project.progress))
                .stroke(progressColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 20, height: 20)
    }

    private var progressColor: Color {
        if project.progress >= 1.0 { return .green }
        if project.progress >= 0.5 { return .orange }
        return .blue
    }
}
