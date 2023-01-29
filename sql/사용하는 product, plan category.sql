use fincette;

select cm_category.code_value,
       cm_plan_category.code_value

from product p
join plan_master plms on p.product_id = plms.product_id
join code_master cm_category on cm_category.code = p.category
join code_master cm_plan_category on cm_plan_category.code = plms.plan_category
where p.status != 'N' and plms.use_yn != 'N'

group by plms.plan_category
order by p.category, plms.plan_category;


-- where cm_category.code_value in ('생활비 지급형', '첨단암치료비형', '암보험')

/*
-- task 1번. code_master update 쿼리
update code_master
set code_value = '생활비 지급형'
where code_value like '암진단비 매월 지급형';

update code_master
set code_value = '최신항암 치료비형'
where code_value like '첨단암치료비형';

-- task 2번. plan_type update 쿼리
update plan_master
set plan_type = '기준 진단비형'
where plan_type like '%진단비형 일반암 진단비%';

update plan_master
set plan_type = '생활비 지급형'
where plan_type = '암진단비 매월 지급형';

update plan_master
set plan_type = '최신항암 치료비형'
where plan_type = '첨단암치료비형';

-- task 3번. plan_type2 update 쿼리
update plan_master
set plan_type2 = trim(concat(LEFT(plan_type2, 3), ' ', SUBSTRING(plan_type2, 9, 4)))
where plan_type2 like '일반암 진단비%';*/

## plan_type2 [변경 전]
# 일반암 진단비 1천만원
# 일반암 진단비 1천만원, 유사암 진단비 2백만원, 고액암 진단비 2천만원, 표적항암 치료비 2천만원 (대면)
# 일반암 진단비 3천만원
# 일반암 진단비 3천만원, 유사암 진단비 6백만원, 고액암 진단비 6천만원, 표적항암 치료비 2천만원 (대면)
# 일반암 진단비 5천만원
# 일반암 진단비 5천만원, 유사암 진단비 1천만원, 고액암 진단비 1억원, 표적항암 치료비 2천만원 (대면)

## plan_type2 [변경 후]
# 일반암 1천만원
# 일반암 3천만원
# 일반암 5천만원