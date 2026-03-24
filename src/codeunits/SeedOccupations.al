codeunit 50143 "Install Occupations"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        Occupation: Record Occupation;
        dictkeys: List of [Text[30]];
        currentKey: Text[30];
        currentValue: Text[30];
        OccupationNamesAndDescriptions: Dictionary of [Text[30], Text[100]];
    begin
        OccupationNamesAndDescriptions.Add('Farmer', 'Farmer');
        OccupationNamesAndDescriptions.Add('Engineer', 'Engineer');
        OccupationNamesAndDescriptions.add('Doctor', 'Doctor');
        OccupationNamesAndDescriptions.Add('Accountant', 'Accountant');
        OccupationNamesAndDescriptions.Add('Teacher', 'Teacher');
        OccupationNamesAndDescriptions.Add('Nurse', 'Nurse');
        dictkeys := OccupationNamesAndDescriptions.Keys();

        foreach currentKey in dictkeys do begin
            currentValue := OccupationNamesAndDescriptions.Get(currentKey);
            Occupation.Init();
            Occupation.Name := currentKey;
            Occupation.Description := currentValue;
            Occupation.Insert(true);
            Clear(Occupation);
        end;


    end;
}