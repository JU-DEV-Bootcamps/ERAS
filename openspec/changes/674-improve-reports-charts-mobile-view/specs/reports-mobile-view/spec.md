# Spec Delta

## Purpose
Defines how the Reports section, meaning its filters, tabs, charts, lists, details panels, tooltip and PDF export, adapts to a mobile screen so that a report can be read and used on a phone.

## ADDED Requirements

### Requirement: The report filters and tabs fit a mobile screen
The system SHALL stack the report filters at full width above the report content on a screen narrower than 768px, and SHALL keep the three report tabs reachable without scrolling the page sideways.

#### Scenario: AC-1 Dynamic Charts filters stack on mobile
**Side:** FE
- **GIVEN** a signed-in user on a 375px wide screen
- **WHEN** they open Reports on the Dynamic Charts tab
- **THEN** the filters Evaluation Process, Cohort, Component and Variable are shown one below the other, each as wide as the screen, with the Apply button below them
- **AND** the page has no horizontal scroll

#### Scenario: AC-2 Report tabs are reachable on mobile
**Side:** FE
- **GIVEN** a signed-in user on a 375px wide screen
- **WHEN** they open Reports
- **THEN** the tabs "Dynamic Charts", "Summary Charts" and "Polls Answered" can each be tapped to open their page
- **AND** the page has no horizontal scroll

### Requirement: The Dynamic Charts fit a mobile screen
The system SHALL show the Dynamic Charts in a single column, one chart below the other, only on a screen narrower than 768px, with each chart, its legend and the buttons of its card inside the width of the screen and the chart labels in a smaller font.

#### Scenario: AC-3 Heatmap charts are one below the other on mobile
**Side:** FE
- **GIVEN** a signed-in user on a 375px wide screen with a Dynamic Charts report of two components shown as heatmaps
- **WHEN** the charts are shown
- **THEN** the two charts are in a single column, the second one below the first one, and each card is as wide as the screen content area
- **AND** the question labels of the heatmaps are shown in a smaller font than on a 1280px wide screen, and the page has no horizontal scroll

#### Scenario: AC-4 Column chart fits the width on mobile
**Side:** FE
- **GIVEN** a Dynamic Charts component shown as a column chart on a 375px wide screen
- **WHEN** the chart is shown
- **THEN** the chart, its title and its legend are fully inside the screen
- **AND** the labels of the axis are shown in a smaller font than on a 1280px wide screen, and the page has no horizontal scroll

#### Scenario: AC-5 Card buttons fit inside the card on mobile
**Side:** FE
- **GIVEN** a Dynamic Charts card on a 375px wide screen
- **WHEN** the card is shown
- **THEN** the Export button, the chart type button and the expand button are inside the card and do not overlap each other
- **AND** the chart title is not covered by any of them

#### Scenario: AC-26 The filters leave space above the charts on mobile
**Side:** FE
- **GIVEN** a signed-in user on a 375px wide screen with a Dynamic Charts report shown
- **WHEN** the filters and the first chart card are shown
- **THEN** there are at least 16px between the Apply button and the first chart card
- **AND** the Apply button does not touch the card

### Requirement: The Summary Charts fit a mobile screen
The system SHALL show the Summary Charts chart, its legend and its Export and chart type buttons inside the width of a screen narrower than 768px, whichever chart type is selected, with the component names on the axes in a smaller font so that the chart itself stays readable.

#### Scenario: AC-6 Summary heatmap and legend fit the width on mobile
**Side:** FE
- **GIVEN** a Summary Charts report shown as a heatmap on a 375px wide screen, with a component named "Socioeconomic"
- **WHEN** the chart is shown
- **THEN** the heatmap and its legend, with the six risk labels wrapped over several lines, are inside the screen
- **AND** the component names, such as "Socioeconomic", are shown in a smaller font than on a 1280px wide screen, and the cells of the heatmap show no numbers
- **AND** the heatmap is wide enough for its cells to be tapped, and scrolls sideways inside its own card, not the page

#### Scenario: AC-7 Summary column chart fits the width on mobile
**Side:** FE
- **GIVEN** a Summary Charts report shown as a column chart on a 375px wide screen, with a component named "Socioeconomic"
- **WHEN** the chart is shown
- **THEN** the chart and its legend are fully inside the screen
- **AND** the component names on the axis are shown in a smaller font than on a 1280px wide screen, and the page has no horizontal scroll

### Requirement: The report lists fit a mobile screen
The system SHALL show each row of the Student Answers list and of the Polls Answered list as a card inside the width of a screen narrower than 768px, with every column of the row.

#### Scenario: AC-8 Student Answers rows are cards on mobile
**Side:** FE
- **GIVEN** a Summary Charts report with the student "Ana Torres" with an average risk of 3.25, on a 375px wide screen
- **WHEN** the Student Answers list is shown
- **THEN** "Ana Torres" is a card with every column of the table, including the average risk badge, and no table is shown
- **AND** the page has no horizontal scroll

#### Scenario: AC-9 Polls Answered rows are cards on mobile
**Side:** FE
- **GIVEN** a Polls Answered report with one poll instance on a 375px wide screen
- **WHEN** the list is shown
- **THEN** the poll instance is a card with every column of the table and its action, and no table is shown
- **AND** the page has no horizontal scroll

#### Scenario: AC-24 Student Answers export controls do not cover the title on mobile
**Side:** FE
- **GIVEN** a Summary Charts report with students, on a 375px wide screen
- **WHEN** the Student Answers list is shown
- **THEN** the title "Student Answers" is shown on its own line with the export format selector and the Export button below it, one below the other
- **AND** the selector and the button are as wide as the list, do not overlap the title and do not make the page scroll sideways

### Requirement: The chart details cover the whole screen on a mobile screen
The system SHALL show the details of a chart element as a screen of its own, centered and as wide as the screen, with a visible close button, on a screen narrower than 768px, and SHALL show the list of students inside the details without scrolling sideways. The details are never a panel beside or over the chart.

#### Scenario: AC-10 Dynamic Charts details open as a centered screen on mobile
**Side:** FE
- **GIVEN** a Dynamic Charts report on a 375px wide screen
- **WHEN** the user taps an element of a chart and then taps the same element again to open its details
- **THEN** the details cover the whole screen, are centered and exactly as wide as the screen, and a close button is visible at the top
- **AND** the page has no horizontal scroll, the details are not pushed to one side, and pressing the close button shows the charts again

#### Scenario: AC-11 Summary heatmap details open as a screen on mobile
**Side:** FE
- **GIVEN** a Summary Charts report shown as a heatmap on a 375px wide screen
- **WHEN** the user taps a cell of the heatmap and then taps the same cell again to open its details
- **THEN** the details are shown as a screen of its own that covers the whole screen, with a visible close button at the top, and the chart is not visible beside it or behind it
- **AND** pressing the close button shows the report again

#### Scenario: AC-12 Summary column chart details open as a screen on mobile
**Side:** FE
- **GIVEN** a Summary Charts report shown as a column chart on a 375px wide screen
- **WHEN** the user taps a column and then taps the same column again to open its details
- **THEN** the details are shown as a screen of its own that covers the whole screen, with a visible close button at the top, and the chart is not visible beside it or behind it
- **AND** pressing the close button shows the report again

#### Scenario: AC-13 The student list in the details fits the screen on mobile
**Side:** FE
- **GIVEN** the details of a chart element with the student "Ana Torres" in their list, on a 375px wide screen
- **WHEN** the details are shown
- **THEN** "Ana Torres" is shown with the student data inside the screen
- **AND** the details have no horizontal scroll

### Requirement: The tooltip is readable and inside the screen on a mobile screen
The system SHALL show, when the user taps a chart element on a screen narrower than 768px, a tooltip that is fully inside the screen with all its text readable, SHALL open the details only when the user taps the same element again, and SHALL hide the tooltip when the details open or when the user taps outside the chart.

#### Scenario: AC-14 Heatmap tooltip is inside the screen on tap
**Side:** FE
- **GIVEN** a Dynamic Charts report shown as a heatmap on a 375px wide screen
- **WHEN** the user taps a cell at the right edge of the chart
- **THEN** the tooltip is shown fully inside the screen, never wider than the screen and with its text readable
- **AND** the details of the cell are not opened by that first tap

#### Scenario: AC-15 Column chart tooltip is inside the screen on tap
**Side:** FE
- **GIVEN** a Summary Charts report shown as a column chart on a 375px wide screen
- **WHEN** the user taps a column at the right edge of the chart
- **THEN** the tooltip is fully inside the screen, never wider than the screen, with its text readable
- **AND** the tooltip does not hide the column that was tapped, and the details of the column are not opened by that first tap

#### Scenario: AC-16 Tapping outside the chart hides the tooltip
**Side:** FE
- **GIVEN** a tooltip shown after a tap on a chart element on a 375px wide screen
- **WHEN** the user taps on the page outside the chart
- **THEN** the tooltip is hidden
- **AND** the report is unchanged

#### Scenario: AC-25 Opening the details hides the tooltip
**Side:** FE
- **GIVEN** a tooltip shown after a first tap on a chart element on a 375px wide screen
- **WHEN** the user taps the same element again and its details open
- **THEN** the tooltip is hidden
- **AND** the details are not covered by the tooltip

### Requirement: A report exported to PDF from a mobile screen matches the desktop one
The system SHALL produce, for a report exported to PDF from a screen narrower than 768px, the same page size, orientation and content as the PDF exported from a desktop screen.

#### Scenario: AC-17 Summary report PDF has the same size on mobile
**Side:** FE
- **GIVEN** the same Summary Charts report shown on a 375px wide screen and on a 1280px wide screen
- **WHEN** the user exports it to PDF on each screen
- **THEN** both PDFs have the same page size and the same orientation
- **AND** the chart in both PDFs is as wide as the page content area

#### Scenario: AC-18 Dynamic chart card PDF has the same size on mobile
**Side:** FE
- **GIVEN** the same Dynamic Charts card shown on a 375px wide screen and on a 1280px wide screen
- **WHEN** the user exports the card to PDF on each screen
- **THEN** both PDFs have the same page size and the same orientation
- **AND** the chart in both PDFs is as wide as the page content area

#### Scenario: AC-19 Summary report PDF keeps the desktop content on mobile
**Side:** FE
- **GIVEN** a Summary Charts report with the student "Ana Torres" on a 375px wide screen
- **WHEN** the user exports it to PDF
- **THEN** the PDF shows the students as a table with every column, as the PDF exported on a desktop screen
- **AND** the PDF shows no card, no close button and no filter

#### Scenario: AC-20 Student list PDF keeps the table on mobile
**Side:** FE
- **GIVEN** the Student Answers list with the student "Ana Torres" on a 375px wide screen
- **WHEN** the user exports the list to PDF
- **THEN** the PDF shows the students as a table with every column, as the PDF exported on a desktop screen
- **AND** the PDF has the same page size and orientation as the one exported on a desktop screen

### Requirement: The app shell keeps its mobile layout while a report is exported to PDF
The system SHALL keep the side menu hidden and the page header in its mobile layout on a screen narrower than 768px while a report is being exported to PDF.

#### Scenario: AC-27 The side menu does not open while a PDF is rendered
**Side:** FE
- **GIVEN** a signed-in user on a 375px wide screen with the side menu hidden
- **WHEN** they export a report to PDF and the report is rendered for the export
- **THEN** the side menu stays hidden and the page header keeps its menu button
- **AND** the page content keeps the full width of the screen

### Requirement: Screens of 768px and wider keep the current Reports section
The system MUST keep the current Reports layout, details panels and tooltip on a screen 768px wide or wider.

#### Scenario: AC-21 Desktop keeps the Dynamic Charts layout
**Side:** FE
- **GIVEN** a signed-in user on a 1280px wide screen with a Dynamic Charts report of two components
- **WHEN** they open the details of a chart element
- **THEN** the filters are in one row, the charts are in two columns with their labels at their current size, and the details panel, 380px wide, is shown beside the charts
- **AND** the details do not cover the charts

#### Scenario: AC-22 Desktop keeps the Summary Charts layout
**Side:** FE
- **GIVEN** a signed-in user on a 1280px wide screen with a Summary Charts report
- **WHEN** they open the details of a chart element
- **THEN** the details panel, 440px wide, is shown beside the report
- **AND** the filters stay in one row, the component names on the chart axes keep their current size, and the Student Answers list is a table with its title and export controls where they are today

#### Scenario: AC-23 Desktop keeps the tooltip behavior
**Side:** FE
- **GIVEN** a signed-in user on a 1280px wide screen with a heatmap shown
- **WHEN** they move the pointer over a cell
- **THEN** the tooltip appears next to the pointer, no wider than 402px, and opens on the left side of the pointer when there is no room on the right
- **AND** the cell is not opened until the user clicks it
