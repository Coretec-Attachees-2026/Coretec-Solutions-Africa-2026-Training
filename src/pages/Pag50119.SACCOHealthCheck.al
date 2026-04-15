// ============================================================
// Page 50119 - SACCO Health Check
// ============================================================
// PURPOSE: System configuration diagnostic page for administrators.
//          Shows the "health status" of critical SACCO setup:
//          - Member Setup and number series
//          - Member Categories
//          - Loan configuration (if enabled)
//          - Email templates and accounts
//          - Test data (members, loan applications)
//
// DESIGN PATTERN:
//   Card page with computed fields populated OnOpenPage
//   Each "check" is a row with Status (Red/Amber/Green),
//   Caption (✓/✗/⚠), and Description text.
//
// HOW COLOR WORKS:
//   StyleExpr = Status + 'Style' on the field will use
//   predefined colors: RedStyle, AmberStyle, GreenStyle
//
// USEr EXPERIENCE:
//   Admin opens this page to diagnose system problems.
//   Green = OK, Amber = Warning, Red = Critical
// ============================================================

page 50119 "SACCO Health Check"
{
    Caption = 'SACCO Health Check';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    layout
    {
        area(Content)
        {
            // ===== OVERALL HEALTH STATUS (HEADER) =====
            group("System Health Status")
            {
                Caption = 'System Health Status';
                Visible = HeaderVisible;

                field(OverallStatus; OverallStatusText)
                {
                    Editable = false;
                    Caption = 'Overall Status';
                    StyleExpr = OverallStatusStyle;
                }

                field(OverallStatusDescription; OverallStatusDescription)
                {
                    Editable = false;
                    Caption = '';
                    MultiLine = true;
                }
            }

            // ===== DETAILED HEALTH CHECKS =====
            group("Configuration Checks")
            {
                Caption = 'Configuration Checks';

                // --- Check 1: Member Setup ---
                group("Setup")
                {
                    Caption = '1. Member Setup Initialization';
                    Visible = DetailedViewVisible;

                    field(Check1_Status; Check1_Status)
                    {
                        Editable = false;
                        Caption = 'Status';
                        StyleExpr = Check1_StatusStyle;
                    }
                    field(Check1_Caption; Check1_Caption)
                    {
                        Editable = false;
                        Caption = 'Indicator';
                    }
                    field(Check1_Description; Check1_Description)
                    {
                        Editable = false;
                        Caption = 'Details';
                        MultiLine = true;
                    }
                }

                // --- Check 2: Member Application No. Series ---
                group("MemberAppNoSeries")
                {
                    Caption = '2. Member Application Number Series';
                    Visible = DetailedViewVisible;

                    field(Check2_Status; Check2_Status)
                    {
                        Editable = false;
                        Caption = 'Status';
                        StyleExpr = Check2_StatusStyle;
                    }
                    field(Check2_Caption; Check2_Caption)
                    {
                        Editable = false;
                        Caption = 'Indicator';
                    }
                    field(Check2_Description; Check2_Description)
                    {
                        Editable = false;
                        Caption = 'Details';
                        MultiLine = true;
                    }
                }

                // --- Check 3: Member Categories ---
                group("MemberCategories")
                {
                    Caption = '3. Member Categories';
                    Visible = DetailedViewVisible;

                    field(Check3_Status; Check3_Status)
                    {
                        Editable = false;
                        Caption = 'Status';
                        StyleExpr = Check3_StatusStyle;
                    }
                    field(Check3_Caption; Check3_Caption)
                    {
                        Editable = false;
                        Caption = 'Indicator';
                    }
                    field(Check3_Description; Check3_Description)
                    {
                        Editable = false;
                        Caption = 'Details';
                        MultiLine = true;
                    }
                }

                // --- Check 4: Loan Application No. Series ---
                group("LoanAppNoSeries")
                {
                    Caption = '4. Loan Application Number Series';
                    Visible = DetailedViewVisible;

                    field(Check4_Status; Check4_Status)
                    {
                        Editable = false;
                        Caption = 'Status';
                        StyleExpr = Check4_StatusStyle;
                    }
                    field(Check4_Caption; Check4_Caption)
                    {
                        Editable = false;
                        Caption = 'Indicator';
                    }
                    field(Check4_Description; Check4_Description)
                    {
                        Editable = false;
                        Caption = 'Details';
                        MultiLine = true;
                    }
                }

                // --- Check 5: Loan Receivable Account ---
                group("LoanReceivableAccount")
                {
                    Caption = '5. Loan Receivable Account (G/L)';
                    Visible = DetailedViewVisible;

                    field(Check5_Status; Check5_Status)
                    {
                        Editable = false;
                        Caption = 'Status';
                        StyleExpr = Check5_StatusStyle;
                    }
                    field(Check5_Caption; Check5_Caption)
                    {
                        Editable = false;
                        Caption = 'Indicator';
                    }
                    field(Check5_Description; Check5_Description)
                    {
                        Editable = false;
                        Caption = 'Details';
                        MultiLine = true;
                    }
                }

                // --- Check 6: Loan Disbursement Account ---
                group("LoanDisbursementAccount")
                {
                    Caption = '6. Loan Disbursement Account (G/L)';
                    Visible = DetailedViewVisible;

                    field(Check6_Status; Check6_Status)
                    {
                        Editable = false;
                        Caption = 'Status';
                        StyleExpr = Check6_StatusStyle;
                    }
                    field(Check6_Caption; Check6_Caption)
                    {
                        Editable = false;
                        Caption = 'Indicator';
                    }
                    field(Check6_Description; Check6_Description)
                    {
                        Editable = false;
                        Caption = 'Details';
                        MultiLine = true;
                    }
                }

                // --- Check 7: Rejection Email Template ---
                group("EmailTemplate")
                {
                    Caption = '7. Rejection Email Template';
                    Visible = DetailedViewVisible;

                    field(Check7_Status; Check7_Status)
                    {
                        Editable = false;
                        Caption = 'Status';
                        StyleExpr = Check7_StatusStyle;
                    }
                    field(Check7_Caption; Check7_Caption)
                    {
                        Editable = false;
                        Caption = 'Indicator';
                    }
                    field(Check7_Description; Check7_Description)
                    {
                        Editable = false;
                        Caption = 'Details';
                        MultiLine = true;
                    }
                }

                // --- Check 8: Email Account ---
                group("EmailAccount")
                {
                    Caption = '8. Email Account Configuration';
                    Visible = DetailedViewVisible;

                    field(Check8_Status; Check8_Status)
                    {
                        Editable = false;
                        Caption = 'Status';
                        StyleExpr = Check8_StatusStyle;
                    }
                    field(Check8_Caption; Check8_Caption)
                    {
                        Editable = false;
                        Caption = 'Indicator';
                    }
                    field(Check8_Description; Check8_Description)
                    {
                        Editable = false;
                        Caption = 'Details';
                        MultiLine = true;
                    }
                }

                // --- Check 9: Loan Applications ---
                group("LoanAppsData")
                {
                    Caption = '9. Loan Applications (Info)';
                    Visible = DetailedViewVisible;

                    field(Check9_Status; Check9_Status)
                    {
                        Editable = false;
                        Caption = 'Status';
                        StyleExpr = Check9_StatusStyle;
                    }
                    field(Check9_Caption; Check9_Caption)
                    {
                        Editable = false;
                        Caption = 'Indicator';
                    }
                    field(Check9_Description; Check9_Description)
                    {
                        Editable = false;
                        Caption = 'Details';
                        MultiLine = true;
                    }
                }

                // --- Check 10: Members ---
                group("MembersData")
                {
                    Caption = '10. Members (Info)';
                    Visible = DetailedViewVisible;

                    field(Check10_Status; Check10_Status)
                    {
                        Editable = false;
                        Caption = 'Status';
                        StyleExpr = Check10_StatusStyle;
                    }
                    field(Check10_Caption; Check10_Caption)
                    {
                        Editable = false;
                        Caption = 'Indicator';
                    }
                    field(Check10_Description; Check10_Description)
                    {
                        Editable = false;
                        Caption = 'Details';
                        MultiLine = true;
                    }
                }
            }

            // ===== LEGEND =====
            group("Legend")
            {
                Caption = 'Legend';
                Visible = DetailedViewVisible;

                field(LegendRed; '✗ Red')
                {
                    Editable = false;
                    Caption = '';
                    StyleExpr = 'Attention';
                }
                field(LegendRedText; 'Critical: System will not function without this configuration')
                {
                    Editable = false;
                    Caption = '';
                }
                field(LegendAmber; '⚠ Amber')
                {
                    Editable = false;
                    Caption = '';
                    StyleExpr = 'Warning';
                }
                field(LegendAmberText; 'Warning: Feature may not work without this configuration')
                {
                    Editable = false;
                    Caption = '';
                }
                field(LegendGreen; '✓ Green')
                {
                    Editable = false;
                    Caption = '';
                    StyleExpr = 'Favorable';
                }
                field(LegendGreenText; 'OK: Configuration is correct')
                {
                    Editable = false;
                    Caption = '';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshHealthCheck)
            {
                Caption = 'Refresh Health Check';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Re-run all health checks and update the display';

                trigger OnAction()
                begin
                    RunAllHealthChecks();
                    CurrPage.Update(false);
                end;
            }

            action(OpenDataQuality)
            {
                Caption = 'Data Quality Finder';
                Image = CheckList;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Analyze data quality issues: duplicate emails, orphaned loans, stalled applications';

                trigger OnAction()
                begin
                    Page.Run(Page::"Data Quality Findings");
                end;
            }

            action(OpenMemberSetup)
            {
                Caption = 'Open Member Setup';
                Image = Edit;
                Promoted = true;
                PromotedCategory = Category5;
                ToolTip = 'Open the Member Setup configuration page';

                trigger OnAction()
                begin
                    Page.Run(Page::"Member Setup");
                end;
            }

            action(OpenMemberCategories)
            {
                Caption = 'Open Member Categories';
                Image = List;
                Promoted = true;
                PromotedCategory = Category5;
                ToolTip = 'Open Member Categories to add/edit member types';

                trigger OnAction()
                begin
                    Page.Run(Page::"Member Category List");
                end;
            }

            action(OpenEmailAccounts)
            {
                Caption = 'Open Email Accounts';
                Image = Email;
                Promoted = true;
                PromotedCategory = Category5;
                ToolTip = 'Configure Email Accounts for sending notifications';

                trigger OnAction()
                begin
                    // Email Accounts page ID varies by BC version
                    // BC 2026+ uses a different configuration method
                    Message('Email Accounts configuration has moved in BC 2026. Please use: Setup > Integration > Email Configuration, or search for "Email Account" in the search box.');
                end;
            }

            action(OpenNumberSeries)
            {
                Caption = 'Open Number Series';
                Image = List;
                Promoted = true;
                PromotedCategory = Category5;
                ToolTip = 'Configure Number Series for generating sequential IDs';

                trigger OnAction()
                begin
                    Page.Run(400); // No. Series List
                end;
            }

            action(OpenGLAccounts)
            {
                Caption = 'Open G/L Accounts';
                Image = List;
                Promoted = true;
                PromotedCategory = Category5;
                ToolTip = 'View General Ledger Accounts';

                trigger OnAction()
                begin
                    Page.Run(131); // Chart of Accounts
                end;
            }

            action(ExportHealthReport)
            {
                Caption = 'Export Health Report';
                Image = Export;
                Promoted = true;
                PromotedCategory = Category5;
                ToolTip = 'Export the health check results as text';

                trigger OnAction()
                begin
                    ExportHealthCheckReport();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        DetailedViewVisible := true;
        HeaderVisible := true;
        RunAllHealthChecks();
    end;

    var
        HealthCheckMgt: Codeunit "Health Check Mgt";

        // Visibility flags
        DetailedViewVisible: Boolean;
        HeaderVisible: Boolean;

        // Overall Status
        OverallStatus: Text;
        OverallStatusText: Text;
        OverallStatusDescription: Text;
        OverallStatusStyle: Text;

        // Check 1: Member Setup
        Check1_Status: Text;
        Check1_Caption: Text;
        Check1_Description: Text;
        Check1_StatusStyle: Text;

        // Check 2: Member App No. Series
        Check2_Status: Text;
        Check2_Caption: Text;
        Check2_Description: Text;
        Check2_StatusStyle: Text;

        // Check 3: Member Categories
        Check3_Status: Text;
        Check3_Caption: Text;
        Check3_Description: Text;
        Check3_StatusStyle: Text;

        // Check 4: Loan App No. Series
        Check4_Status: Text;
        Check4_Caption: Text;
        Check4_Description: Text;
        Check4_StatusStyle: Text;

        // Check 5: Loan Receivable Account
        Check5_Status: Text;
        Check5_Caption: Text;
        Check5_Description: Text;
        Check5_StatusStyle: Text;

        // Check 6: Loan Disbursement Account
        Check6_Status: Text;
        Check6_Caption: Text;
        Check6_Description: Text;
        Check6_StatusStyle: Text;

        // Check 7: Rejection Email Template
        Check7_Status: Text;
        Check7_Caption: Text;
        Check7_Description: Text;
        Check7_StatusStyle: Text;

        // Check 8: Email Account
        Check8_Status: Text;
        Check8_Caption: Text;
        Check8_Description: Text;
        Check8_StatusStyle: Text;

        // Check 9: Loan Applications (Info)
        Check9_Status: Text;
        Check9_Caption: Text;
        Check9_Description: Text;
        Check9_StatusStyle: Text;

        // Check 10: Members (Info)
        Check10_Status: Text;
        Check10_Caption: Text;
        Check10_Description: Text;
        Check10_StatusStyle: Text;

    /// <summary>
    /// Run all health checks and populate the display variables
    /// </summary>
    local procedure RunAllHealthChecks()
    begin
        // Run each check and capture results
        HealthCheckMgt.CheckMemberSetupExists(Check1_Status, Check1_Caption, Check1_Description);
        Check1_StatusStyle := StatusToStyle(Check1_Status);

        HealthCheckMgt.CheckMemberAppNoSeries(Check2_Status, Check2_Caption, Check2_Description);
        Check2_StatusStyle := StatusToStyle(Check2_Status);

        HealthCheckMgt.CheckMemberCategoriesExist(Check3_Status, Check3_Caption, Check3_Description);
        Check3_StatusStyle := StatusToStyle(Check3_Status);

        HealthCheckMgt.CheckLoanAppNoSeries(Check4_Status, Check4_Caption, Check4_Description);
        Check4_StatusStyle := StatusToStyle(Check4_Status);

        HealthCheckMgt.CheckLoanReceivableAccount(Check5_Status, Check5_Caption, Check5_Description);
        Check5_StatusStyle := StatusToStyle(Check5_Status);

        HealthCheckMgt.CheckLoanDisbursementAccount(Check6_Status, Check6_Caption, Check6_Description);
        Check6_StatusStyle := StatusToStyle(Check6_Status);

        HealthCheckMgt.CheckRejectionEmailTemplate(Check7_Status, Check7_Caption, Check7_Description);
        Check7_StatusStyle := StatusToStyle(Check7_Status);

        HealthCheckMgt.CheckEmailAccountConfigured(Check8_Status, Check8_Caption, Check8_Description);
        Check8_StatusStyle := StatusToStyle(Check8_Status);

        HealthCheckMgt.CheckLoanApplicationsExist(Check9_Status, Check9_Caption, Check9_Description);
        Check9_StatusStyle := StatusToStyle(Check9_Status);

        HealthCheckMgt.CheckMembersExist(Check10_Status, Check10_Caption, Check10_Description);
        Check10_StatusStyle := StatusToStyle(Check10_Status);

        // Get overall health status
        OverallStatusDescription := HealthCheckMgt.GetOverallHealthStatus(OverallStatus);
        OverallStatusStyle := StatusToStyle(OverallStatus);

        // Set overall status text with indicator
        case OverallStatus of
            'Red':
                OverallStatusText := '✗ CRITICAL - Action Required';
            'Amber':
                OverallStatusText := '⚠ WARNING - Review Configuration';
            'Green':
                OverallStatusText := '✓ HEALTHY - All Systems OK';
            else
                OverallStatusText := '? UNKNOWN STATUS';
        end;
    end;

    /// <summary>
    /// Convert health status (Red/Amber/Green) to BusinessCentral style name
    /// </summary>
    local procedure StatusToStyle(Status: Text): Text
    begin
        case Status of
            'Red':
                exit('Attention');
            'Amber':
                exit('Warning');
            'Green':
                exit('Favorable');
            else
                exit('');
        end;
    end;

    /// <summary>
    /// Export health check results as a text report  
    /// </summary>
    local procedure ExportHealthCheckReport()
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        ReportText: Text;
        OutStream: OutStream;
    begin
        // Build report content
        TempBlob.CreateOutStream(OutStream);

        OutStream.WriteText('SACCO HEALTH CHECK REPORT');
        OutStream.WriteText();
        OutStream.WriteText('=====================================');
        OutStream.WriteText();
        OutStream.WriteText('Generated: ' + Format(System.CurrentDateTime()));
        OutStream.WriteText();
        OutStream.WriteText();

        OutStream.WriteText('OVERALL STATUS: ' + OverallStatusText);
        OutStream.WriteText(OverallStatusDescription);
        OutStream.WriteText();
        OutStream.WriteText();

        OutStream.WriteText('DETAILED CHECKS:');
        OutStream.WriteText('1. Member Setup: ' + Check1_Caption + ' - ' + Check1_Description);
        OutStream.WriteText('2. Member App No. Series: ' + Check2_Caption + ' - ' + Check2_Description);
        OutStream.WriteText('3. Member Categories: ' + Check3_Caption + ' - ' + Check3_Description);
        OutStream.WriteText('4. Loan App No. Series: ' + Check4_Caption + ' - ' + Check4_Description);
        OutStream.WriteText('5. Loan Receivable Account: ' + Check5_Caption + ' - ' + Check5_Description);
        OutStream.WriteText('6. Loan Disbursement Account: ' + Check6_Caption + ' - ' + Check6_Description);
        OutStream.WriteText('7. Rejection Email Template: ' + Check7_Caption + ' - ' + Check7_Description);
        OutStream.WriteText('8. Email Account: ' + Check8_Caption + ' - ' + Check8_Description);
        OutStream.WriteText('9. Loan Applications: ' + Check9_Caption + ' - ' + Check9_Description);
        OutStream.WriteText('10. Members: ' + Check10_Caption + ' - ' + Check10_Description);
        OutStream.WriteText();
        OutStream.WriteText('END OF REPORT');

        // Download file
        FileMgt.BLOBExport(TempBlob, 'SACCO_HealthCheck_' + Format(System.Today(), 0, '<Year4><Month,2><Day,2>') + '.txt', true);
    end;
}
