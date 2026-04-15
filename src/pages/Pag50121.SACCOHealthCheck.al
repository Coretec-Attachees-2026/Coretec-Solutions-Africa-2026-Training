// ============================================================
// Page 50121 - Setup Health Check
// ============================================================
// PURPOSE: Displays a health check dashboard for SACCO system
//          configuration. Admin can view pass/fail/warning status
//          for all critical settings and get recommendations.
//
// KEY FEATURES:
//   - Color-coded status indicators (Green/Amber/Red via StyleExpr)
//   - Automatic checks on page open
//   - Actions to open related pages for fixes
//   - Refresh button to re-run checks
//   - Overall system status summary
//
// HOW IT WORKS:
//   1. OnOpenPage: Runs PerformAllHealthChecks() to populate temp table
//   2. Page displays results in a list/repeater format
//   3. Each row shows: Check Name, Status, Details, Recommendation
//   4. Admin can click action buttons to open related setup pages
// ============================================================

page 50121 "SACCO Health Check"
{
    PageType = Document;
    SourceTable = "Setup Health Check";
    Caption = 'SACCO Health Check';
    ApplicationArea = All;
    UsageCategory = Administration;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            // ----- Overall Status Section -----
            group("System Status")
            {
                Caption = 'System Health Status';
                Visible = true;

                field(OverallStatus; OverallStatusText)
                {
                    Caption = 'Overall Status';
                    Editable = false;
                    StyleExpr = OverallStatusStyle;
                    ToolTip = 'Indicates if critical configuration is complete. CRITICAL means the system cannot function. AT RISK means some features may not work. HEALTHY means ready for use.';
                }

                field(LastCheckTime; LastCheckTime)
                {
                    Caption = 'Last Check Performed';
                    Editable = false;
                    ToolTip = 'Shows when the health check was last run.';
                }
            }

            // ----- Configuration Checks List -----
            repeater(HealthChecks)
            {
                Caption = 'Configuration Checks';
                field("Entry No."; rec."Entry No.")
                {
                    Visible = false;
                }

                field("Check Name"; rec."Check Name")
                {
                    Caption = 'Check';
                    ToolTip = 'The configuration item being checked.';
                }

                field(StatusDisplay; GetStatusDisplay(rec.Status))
                {
                    Caption = 'Status';
                    ToolTip = 'Green = Configured. Amber = Warning. Red = Critical issue.';
                }

                field("Details"; rec."Details")
                {
                    Caption = 'Details';
                    ToolTip = 'What is currently configured or what''s missing.';
                }

                field("Recommendation"; rec."Recommendation")
                {
                    Caption = 'Recommendation';
                    ToolTip = 'Steps to fix the issue.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // ----- Refresh Checks -----
            action(RefreshChecks)
            {
                Caption = 'Refresh Health Checks';
                ToolTip = 'Re-run all configuration checks (e.g., after making changes).';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    RefreshHealthChecks();
                    Message('Health checks completed.');
                end;
            }

            action(OpenMemberSetup)
            {
                Caption = 'Open Member Setup';
                ToolTip = 'Go to Member Setup to configure number series and GL accounts.';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Page.Run(Page::"Member Setup");
                end;
            }

            action(OpenMemberCategories)
            {
                Caption = 'Open Member Categories';
                ToolTip = 'Go to Member Category Master to set up member categories.';
                Image = List;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Page.Run(Page::"Member Category List");
                end;
            }

            action(OpenEmailAccounts)
            {
                Caption = 'Open Email Accounts';
                ToolTip = 'Go to Email Accounts to configure the default email account for sending notifications.';
                Image = Email;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    // Email Accounts is a standard BC page - ID varies by version
                    // We use RunModal with the page name instead
                    Page.Run(6308); // Standard Email Account page ID in BC
                end;
            }
        }
    }

    // ===== LOCAL PROCEDURES =====

    trigger OnOpenPage()
    begin
        // Initialize and run all checks
        RefreshHealthChecks();
    end;

    local procedure RefreshHealthChecks()
    var
        HealthCheckMgt: Codeunit "Setup Health Check Manager";
    begin
        // Run all checks and populate this table
        HealthCheckMgt.PerformAllHealthChecks(rec);

        // Refresh the repeater
        CurrPage.Update(false);

        // Update overall status text
        UpdateOverallStatus();

        // Set timestamp
        LastCheckTime := CurrentDateTime;
    end;

    local procedure UpdateOverallStatus()
    var
        HealthCheckMgt: Codeunit "Setup Health Check Manager";
    begin
        rec.FindFirst();
        OverallStatusText := HealthCheckMgt.GetOverallSystemStatusText(rec);
        OverallStatusStyle := HealthCheckMgt.GetOverallSystemStyle(rec);
    end;

    local procedure GetStatusDisplay(StatusValue: Integer): Text
    begin
        case StatusValue of
            0: // Green
                exit('✓ PASS');
            1: // Amber
                exit('⚠ WARNING');
            2: // Red
                exit('✗ CRITICAL');
            else
                exit('Unknown');
        end;
    end;

    // ===== PAGE VARIABLES =====
    var
        OverallStatusText: Text;
        OverallStatusStyle: Text;
        LastCheckTime: DateTime;
}
