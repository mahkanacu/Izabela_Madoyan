-- 1
-- Գտնել բոլոր դրամա ժանրի ֆիլմերը և դրանց գլխավոր դերասաններին։ 
-- Լրացնել ֆիլմի անունը, ժանրի անունը, դերասանների անունները և կերպարների անունները։
-- Սահմանափակել 20-ով։
select m.title, 
       g.genre_name, 
	   p.name as actor_name, 
	   mc.character_name
from movies_schema.movies m
join movies_schema.movie_genres mg on m.movie_id = mg.movie_id 
join movies_schema.genres g on mg.genre_id = g.genre_id
join movies_schema.movie_cast mc on m.movie_id = mc.movie_id 
join movies_schema.people p on mc.person_id = p.person_id
where g.genre_name = 'Drama'
limit 20;

-- 2
-- Գտնել յուրաքանչյուր ժանրի ֆիլմերի քանակը և ընդհանուր եկամուտը:
-- Լրացնել ժանրի տեսակը, տվյալ ժանրի ֆիլմերի քանակը և ընդհանուր եկամուտը։
-- Ընդհանուր եկամուտը դասավորել նվազման կարգով։
select 
    g.genre_name as Genre, 
    count(m.movie_id) as Movie_Count, 
    sum(m.revenue) as Total_Revenue
from  movies_schema.genres g
join  movies_schema.movie_genres mg on g.genre_id = mg.genre_id
join  movies_schema.movies m on mg.movie_id = m.movie_id 
group by g.genre_name
order by Total_Revenue desc;

-- 3
-- Գտնել ֆիլմեր, որոնց եկամուտը (revenue) գերազանցում է բյուջեն (budget):
-- Լրացնել ֆիլմի վերնագիրը և շահույթը (profit):
-- Շահույթը դասավորել նվազման կարգով։
select title, (revenue - budget) as profit
from movies_schema.movies 
where revenue > budget 
order by profit desc;

-- 4
-- Գտնել այն դերասաններին, ովքեր ունեն գոնե 2 դեր բազայում:
-- Լրացնել դերասանի անունը և ընդհանուր դերերի քանակը (Total_Roles):
-- Դասավորել ընդհանուր դերերի քանակը նվազման կարգով։
select p.name, 
count(mc.movie_id) as Total_Roles
from movies_schema.people p
join movies_schema.movie_cast mc on p.person_id = mc.person_id
group by p.name
having count(mc.movie_id) >= 2
order by Total_Roles desc;

-- 5
-- Յուրաքանչյուր ժանրի ներսում դասակարգել ֆիլմերն ըստ հանրաճանաչության:
-- Լրացնել ժանրի անունը, ֆիլմի վերնագիրը, հանրաճանաչությունը։
select 
    g.genre_name, 
    m.title, 
    m.popularity,
    rank() over (partition by g.genre_name order by m.popularity desc) as Rank_in_Genre
from movies_schema.movies m
join movies_schema.movie_genres mg on m.movie_id = mg.movie_id 
join movies_schema.genres g on mg.genre_id = g.genre_id;

-- 6
-- Գտնել յուրաքանչյուր ժանրի ամենաբարձր վարկանիշ ունեցող ֆիլմը։
-- Լրացնել ժանրի անունը, ֆիլմի վերնագիրը և վարկանիշը։
select genre_name, title, popularity 
from (select g.genre_name, m.title, m.popularity, 
rank() over(partition by g.genre_name order by m.popularity desc) as rnk 
from movies_schema.movies m 
join movies_schema.movie_genres mg on m.movie_id = mg.movie_id 
join movies_schema.genres g on mg.genre_id = g.genre_id) t 
where rnk = 1;

-- 7
-- Համեմատել ֆիլմի եկամուտը նախորդ և հաջորդ թողարկված ֆիլմերի հետ:
-- Լրացնել ֆիլմի վերնագիրը, թողարկման ամսաթիվ(release date), եկամուտը։
select 
    title, 
    release_date, 
    revenue,
    lag(revenue) over (order by release_date) as Previous_Movie_Revenue,
    sum(revenue) over (order by release_date) as Running_Total_Revenue
from movies_schema.movies
where revenue > 0;

-- 8
-- Գտնել այն դերասաններին, ովքեր խաղացել են միջինից բարձր բյուջե ունեցող ֆիլմերում:
-- Լրացնել դերասանի անունը, ֆիլմի վերնագրի անունը և համապատասխան բյուջեն։
with AverageBudget as (
    select avg(budget) as avg_b 
	from movies_schema.movies 
	where budget > 0
)
select distinct p.name as Actor_Name,
                m.title as Movie_Title,  
                m.budget as Movie_Budget
from movies_schema.people p
join movies_schema.movie_cast mc on p.person_id = mc.person_id
join movies_schema.movies m on mc.movie_id = m.movie_id 
where m.budget > (select avg_b from AverageBudget)
order by m.budget desc;

-- 9
-- Դասակարգել ֆիլմերը ըստ տևողության և ստանալ թողարկման տարին:
-- Եթե ֆիլմը տևում է 1 ժամ, ապա դասակագրել որպես Short(կարճամետրաժ), եթե 1 ժամից ավել և 
-- 1․5 ժամից կարճ ֆիլմերը՝ Feature(լիամետրաժ), 1․5 ժամից ավել ՝ Epic։
select 
    title, 
    extract(year from release_date) as Release_Year,
    case 
        when runtime between 1 and 60 then 'Short'
        when runtime between 61 and 150 then 'Feature'
        else 'Epic'
    end as "Duration_Category"
from movies_schema.movies;

-- 10
-- Ստուգել հարցման արդյունավետությունը Modern Partition-ի վրա:
explain analyze
select * from movies_schema.movies 
where release_date >= '2020-01-01' and release_date <= '2025-12-31';




