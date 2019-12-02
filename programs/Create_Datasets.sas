*Create_Datasets.sas creates all the SAS data sets
 used in A Gentle Introduction to Statistics Using 
 SAS Studio;

*Change the line below to a shared folder or a folder
 that your SAS programs can access;
 
libname Stats "/folders/myfolders";

*Stats.Reading;
data Stats.Reading;
   call streaminit(13579);
   do i = 1 to 20;
      do Gender = 'M','F';
         do Method = 'A','B','C';
            Subject + 1;
            Words_per_Minute = rand('normal',225,20);
            if Gender = 'M' then Words_per_Minute = Words_per_Minute - 10;
            if Method = 'B' then Words_per_Minute = Words_per_Minute + 15;
            else if Method = 'C' then Words_per_Minute = Words_per_Minute - 12;
            output;
         end;
      end;
   end;
   drop i;
run;

*Stats.Exercise;
data Stats.Exercise;
   call streaminit(13579);
   do i = 1 to 20;
      do Gender = 'M','F';
         Do Training = '10','20','30';
            do Dose = 'Placebo','100 mg';
               Subject + 1;
               Pushups = rand('normal',20,5);
               Flexibility = rand('norma',5,2);
               Strength = int(100*rand('exponential'));
               Pushups = int(Pushups + 10*(Gender='M') + input(Training,5.));
               Flexibility = int(Flexibility + 20*(Gender = 'F') + input(Training,5.));
               Strength = int(Strength + 20*(Gender='M') - 40*(Gender='F' and Dose = '100 mg')
                          + input(training,5.) + 10*(Dose='100 mg'));
               output;
            end;
         end;
      end;
   end;
   drop i;
run;

*Data set Stat.Exercise2;
data Stats.Exercise2;
   call streaminit(11223344);
   do i = 1 to 10;
      do Gender = 'M','F';
         Do Training = '10','20','30';
            do Dose = 'Placebo','100 mg';
               Subject + 1;
               Flexibility = rand('normal',5,2) + 3*(Gender='F') + .25*Training;
               Strength = int(rand('normal',10,5) + 10*(Gender='M') 
                          - 10*(Gender='F' and Dose = '100 mg') + input(training,5.)
                          + 10*(Dose='100 mg'));
               Pushups = int(rand('normal',15,5) + 10*(Gender='M') + input(Training,5.)*.25
                             + .25*Strength);
               Endurance = int(Strength + rand('uniform')*15);
               output;
            end;
         end;
      end;
   end;
   drop i;
run;

*Data set Stats.Height_Weight;
data Stats.Height_Weight;
   call streaminit(13579);
   do i = 1 to 20;
      Height = int(rand('normal',48,10));
      Weight = int(rand('normal',20,5) + Height);
      output;
   end;
   drop i;
run;

*Data set Stats.Risk;
data Stats.Risk;
   call streaminit(13579);
   length Age_Group $ 10;
   do i = 1 to 250;
      do Gender = 'F','M';
         Age = round(rand('uniform')*30 + 50);
         if missing(Age) then Age_Group = ' ';
         else if Age lt 60 then Age_Group = '1:Less 60';
         else if Age le 70 then Age_Group = '2:61 to 70';
         else Age_Group = '3:Over 70';
         Chol = rand('normal',200,30) + rand('uniform')*8*(Gender='M');
         Chol = round(Chol);
         if Chol le 200 and not missing(Chol) then Chol_High = '0';
         else if Chol gt 200 then chol_High = '1';
         Score = .3*chol + age + 8*(Gender eq 'M');
         Heart_Attack = (Score gt 130)*(rand('uniform') lt .2);
         output;
       end;
   end;
   keep Gender Age Age_Group chol Heart_Attack Chol_High;
run;
*Adding formats to the Risk Dataset;
proc format;
   value $gender 'F' = 'Female'
                 'M' = 'Male';
   value Yesno 0 = 'No'
               1 = 'Yes';
   value $Yesno '0'='Yes'
                '1'='No';
run;

data Risk;
   set Stats.Risk;
   format Gender $Gender.
          Heart_Attack Yesno.
          Chol_High $Yesno.
run;

*Data set Stats.Salary;
*First make Work data set;
data Salary;
   call streaminit(13579);
   do i = 1 to 1000;
      do Gender = 'F','M';
         do Age_Group = '20-24','45-54';
            do Education = '<HS','BA+';
               Weekly_Salary = round(rand('normal',820,100) + 437*(Age_Group = '45-54')
                               + 759*(Education = 'BA+') - 200*(Gender = 'F'));
               output;
               *Create some extra observation for males;
               if i = 1 and Gender = 'M' then do j = 1 to 200;
                  Weekly_Salary = round(rand('normal',820,100) + 437*(Age_Group = '45-54')
                               + 759*(Education = 'BA+'));
                  output;
               end;
            end;
         end;
      end;
   end;
   drop i j;
   format Weekly_Salary Dollar8.;
run;

*Use PROC RANK with Groups=2 to do a median cut;
proc rank data=Salary out=Stats.Salary groups=2;
   var Weekly_Salary;
   ranks Salary;
run;

*Creating formats to the Salary Dataset;
proc format;
   value $Gender 'F' = 'Female'
                 'M' = 'Male';
   value Median 0 = 'Below the Median'
                1 = 'Above the Median';
run;
data Stats.Salary_Formatted;
   set Stats.Salary;
   format Gender $Gender.
          Salary Median.;
run;

*Code to create the table to demonstrate Fisher's Exact Test;
data Fisher;
   input Row Column Count;
datalines;
1 1 2
1 2 10
2 1 7
2 2 4
;

*Data Set High_School, used in several of the exercises;
proc format;
   value Cut 0 = 'No' 1 = 'Yes';
run;

Data First;
   call streaminit(11223344);
   length Grade $ 9 Gender $ 6;
   do i = 1 to 50;
      do Grade = 'Freshman','Sophomore','Junior','Senior';
         do Gender = 'Male','Female';
            Vocab_Score = round(rand('normal',75,20) +
                                10*(Grade = 'Sophomore') +
                                20*(Grade = 'Junior') +
                                22*(Grade = 'Senior') +
                                 5*(Gender = 'Female'));
            Spelling_Score = round(rand('uniform')*90 + .75*Vocab_Score);
            English_Grade = round(rand('uniformn')*60 + .15*Vocab_Score
                                  + .15*Spelling_Score);
            if English_Grade gt 100 then English_Grade = English_Grade - 25;
            else if English_Grade lt 60 then English_Grade = English_Grade + 40;
            Honor = Vocab_Score + Spelling_Score + English_Grade;
            output;
         end;
      end;
   end;
   drop i;
run;

proc rank data=First Out=Stats.High_School groups=2;
   var Honor;
   format Honor Cut.;
   label Honor = 'Honor Society';
run;
 
*Data set Stats.Interact;
Data Stats.Interact;
   call streaminit(23456);
   do i = 1 to 50;
      do Seniority = 'Long time','Beginner';
         do Training = 'Yes','No';
            Parts = int(rand('normal',1000,100) + 500*(Seniority='Longtime')
                    + 100*(Seniority='Beginner' and Training = 'Yes')
                    + 50*(Seniority='Long time' and Training='Yes'));
            output;
         end;
      end;
   end;
   drop i;
run;

*Data set Stats.Physics_Test;
data Stats.Physics_Test;
   call streaminit(13579);
   array Ans[10];
   do Student = 1 to 100;
      Grade = round(rand('normal',75,15));
      *Make sure no Grade is greater than 100;
      if Grade gt 100 then grade = Grade - 20;
      Do Question = 1 to 10;
         Ans[Question] = rand('Bernoulli',.01*Grade);
      end;
      output;
   end;
run;

*Data set Stats.Graduate;
proc format;
   value Study 0='Below Average' 1='Above Averge';
   value Graduate 0='No' 1='Yes';
run;

data Stats.Graduate;
   call streaminit(13579);
   do i = 1 to 150;
      do Gender = 'F','M';
         if rand('uniform') gt .15 then Graduate = 1;
         else Graduate = 0;
         English_Grade = round(rand('normal',78,10) + 20*Graduate);
         if English_Grade gt 100 then English_Grade = 90 + round(rand('uniform')*10);
         Math_Grade = round(.5*English_Grade + round(rand('uniform')*75) + 
             25*(Graduate));
         if Math_Grade gt 100 then Math_Grade = 90 + round(rand('uniform')*10);
         else if Math_Grade lt 55 then Math_Grade = Math_Grade + 25;
         Hours_Study = round(rand('uniform')*20 + 10*Graduate);
         If Hours_Study gt 17 then Study = 1;
         else Study = 0;
         output;
      end;
   end;
   drop i;
   format Study Study. Graduate Graduate.;
run;
   
*Data set Before_After;
data Before_After;
   N + 1;
   input Difference @@;
datalines;
0 -11 4 6 -2 50 75 32 -1 17 -1 7 4 9 7
;

*Data set Difference;
data Difference;
   call streaminit(13579);
   do Subj = 1 to 20;
      Diff = .6 - rand('uniform');
      output;
   end;
run;

*Data set TTest;
data TTest;
   call streaminit(13579);
   do Subj = 1 to 10;
      Do Group = 'A','B';
         X = round(rand('normal',100,15) + 10*(Group = 'B'));
         output;
      end;
   end;
run;

*Data set Temp;
data Temp;
   set Stats.Salary_Formatted;
   length Gender_Age $ 6;
   Gender_Age = Cats(Gender, Age_Group);
run;

*Data set XY;
data XY;
   call streaminit(13579);
   do i = 1 to 9;
      x = round(rand('uniform')*100);
      y = round(.75*x + rand('uniform')*10);
      output;
   end;
   x = 95;
   y = 5;
   output;
   drop i;
run;

*Program for exercise 9-3;
data Temp;
   set Stats.Salary_Formatted;
   length Gender_Age $ 6;
   Gender_Age = cats(Gender, Age_Group);
run;
 

