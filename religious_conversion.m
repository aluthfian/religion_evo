clear
%% initial population
maxpop=100;
king_age=30;
maxtime=50;
king_suscep=3;
preach_suscep=1;
preach_inf=0.5;
pdf_fun=makedist('Weibull',1,1.45);
rng('default')
pop_age=random(pdf_fun,10,10);
pop_age=round(75*(pop_age./max(pop_age)));
pop_rel=zeros([10,10,maxtime+1]);
pop_rel(:,:,1)=zeros(10,10);
pop_rel_app=zeros([10,10,maxtime+1]);
pop_rel_app(:,:,1)=zeros(10,10)-1;
pop_suscep=round(9.8.*rand(10,10)+0.2);
pop_tag=zeros([10,10,maxtime]);
%% king
idx_king=randi(maxpop,1,1);
[king_row,king_col]=ind2sub([10,10],idx_king);
pop_age(king_row,king_col)=king_age;
pop_rel(king_row,king_col,1)=-1;
pop_suscep(king_row,king_col)=king_suscep;
pop_tag(king_row,king_col,1)=-1;
%% religious conversion
for time=1:maxtime
    [king_row,king_col,~]=find(pop_tag(:,:,time)==-1);
    [row_preach,col_preach,~]=find(pop_tag(:,:,time)==1);
    if all(pop_rel_app(:,:,time)==-1)
        idx_preacher=randi(maxpop,1,1);
        if pop_age(idx_preacher)>17&&pop_age(idx_preacher)<35
            [row_preach,col_preach]=ind2sub([10,10],idx_preacher);
            pop_rel(row_preach,col_preach,time)=1;
            pop_rel_app(row_preach,col_preach,time)=1;
            pop_suscep(row_preach,col_preach)=preach_suscep;
            pop_tag(row_preach,col_preach,time)=1;
        end
    end
    for idx=1:100
        [idx_row,idx_col]=ind2sub([10,10],idx);
        if ~isempty(row_preach)
            if pop_tag(idx_row,idx_col,time)==0
                dist2preach=sqrt(power(idx_row-row_preach,2)+power(idx_col-col_preach,2));
                dist2king=sqrt(power(idx_row-king_row,2)+power(idx_col-king_col,2));
                pop_rel(idx_row,idx_col,time+1)=pop_rel(idx_row,idx_col,time)+(-gaussmf(dist2king,[abs(10.1-pop_suscep(idx_row,idx_col)) 0])...
                    +gaussmf(dist2preach,[pop_suscep(idx_row,idx_col) 0]));
            elseif pop_tag(idx_row,idx_col,time)==1
                dist2king=sqrt(power(idx_row-king_row,2)+power(idx_col-king_col,2));
                pop_rel(idx_row,idx_col,time+1)=pop_rel(idx_row,idx_col,time)-gaussmf(dist2king,[preach_suscep 0]);
            elseif pop_tag(idx_row,idx_col,time)==-1
                dist2preach=sqrt(power(idx_row-row_preach,2)+power(idx_col-col_preach,2));
                pop_rel(idx_row,idx_col,time+1)=pop_rel(idx_row,idx_col,time)+gaussmf(dist2preach,[king_suscep 0]);
            end
            if pop_rel(idx_row,idx_col,time+1)>0.5
                pop_rel_app(idx_row,idx_col,time+1)=1;
            else
                pop_rel_app(idx_row,idx_col,time+1)=-1;
            end
        else
            pop_rel(:,:,time+1)=zeros(size(10,10));
            pop_rel_app(:,:,time+1)=zeros(size(10,10))-1;
        end
    end
    randomizer=randperm(100,100);
    [random_row,random_col]=ind2sub([10,10],randomizer);
    random_row=reshape(random_row,[10,10]);
    random_col=reshape(random_col,[10,10]);
    for row=1:10
        for col=1:10
            pop_age(row,col)=pop_age(random_row(row,col),random_col(row,col));
            pop_rel(row,col,time+1)=pop_rel(random_row(row,col),random_col(row,col),time+1);
            pop_rel_app(row,col,time+1)=pop_rel_app(random_row(row,col),random_col(row,col),time+1);
            pop_suscep(row,col)=pop_suscep(random_row(row,col),random_col(row,col));
            pop_tag(row,col,time+1)=pop_tag(random_row(row,col),random_col(row,col),time);
        end
    end
    age_death=(85-75).*rand(1,1) + 75;
    idx_death=find(pop_age>=age_death);
    [death_row,death_col]=ind2sub([10,10],idx_death);
    if isempty(idx_death)
        pop_age=pop_age+1;
    else
        idx_choice_die=idx_death(randi(length(idx_death),1));
        pop_age(idx_choice_die)=0;
        for idx=1:length(death_row)
            if pop_tag(death_row(idx),death_col(idx),time+1)~=-1
                pop_tag(death_row(idx),death_col(idx),time+1)=0;
            else
                pop_tag(death_row(idx),death_col(idx),time+1)=0;
                idx_king=randi(maxpop,1,1);
                [king_row,king_col]=ind2sub([10,10],idx_king);
                pop_tag(king_row,king_col,time+1)=-1;
            end
        end
        pop_age=pop_age+1;
    end
end
%% plotting
time_choice=3;
imagesc(pop_rel_app(:,:,time_choice))
hold on
[king_row,king_col,~]=find(pop_tag(:,:,time_choice)==-1);
scatter(king_col,king_row)
[row_preach,col_preach,~]=find(pop_tag(:,:,time_choice)==1);
scatter(col_preach,row_preach)
hold off
set(gca,'xticklabel',[])
set(gca,'yticklabel',[])
set(gca,'xtick',0.5:9.5)
set(gca,'ytick',0.5:9.5)