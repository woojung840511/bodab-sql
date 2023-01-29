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

