use fincette;

-- 암, 치아 product 상품 상태별 개수 확인
select count(case
                 when cm_category.code_value in ('생활비 지급형', '첨단암치료비형', '암보험') and p.status in ('S')
                     then 1 end) as '암보험 - 작업완료',
       count(case
                 when cm_category.code_value in ('생활비 지급형', '첨단암치료비형', '암보험') and p.status in ('S', 'W')
                     then 1 end) as '암보험 - 작업대상',
       count(case
                 when cm_category.code_value in ('치아보험') and p.status in ('S')
                     then 1 end) as '치아보험 - 작업완료',
       count(case
                 when cm_category.code_value in ('치아보험') and p.status in ('S', 'W')
                     then 1 end) as '치아보험 - 작업대상'
from product p
         join code_master cm_category on cm_category.code = p.category;

-- 회사별 담당자 확인
select c.short_name,
       case
           when c.short_name in ('DBL', 'DBF', 'HNL', 'KLP', 'MGF'
               ) then '김용준'
           when c.short_name in ('ABL', 'AXF', 'HDF', 'HKL', 'HWL', 'LIN', 'LTF'
               ) then '김인우'
           when c.short_name in ('CBL', 'BPL', 'IBK'
               ) then '손문수'
           when c.short_name in ('HDL', 'SFI', 'SLI', 'PLI'
               ) then '노우정'
           when c.short_name in ('KBF', 'KBL', 'KDB', 'NHF', 'NHL'
               ) then '박민철'
           when c.short_name in ('KYO', 'MEZ'
               ) then '김보배'
           when c.short_name in ('AIG', 'DGL', 'HMF', 'HNF', 'HWF', 'MRA', 'MTL', 'PST'
               ) then '조하연'
           when c.short_name in ('ACF', 'AIL', 'CRF', 'SHL', 'TYL'
               ) then '최우진'
           end as worker
from company c
;

# 담당자별 남은 작업 - 상품 단위
select w.worker,
       p.product_id,
       p.status
from product p
         join code_master cm_category on cm_category.code = p.category
         join company c on p.company_id = c.company_id
         join (select c.short_name,
                      case
                          when c.short_name in ('DBL', 'DBF', 'HNL', 'KLP', 'MGF'
                              ) then '김용준'
                          when c.short_name in ('ABL', 'AXF', 'HDF', 'HKL', 'HWL', 'LIN', 'LTF'
                              ) then '김인우'
                          when c.short_name in ('CBL', 'BPL', 'IBK'
                              ) then '손문수'
                          when c.short_name in ('HDL', 'SFI', 'SLI', 'PLI'
                              ) then '노우정'
                          when c.short_name in ('KBF', 'KBL', 'KDB', 'NHF', 'NHL'
                              ) then '박민철'
                          when c.short_name in ('KYO', 'MEZ'
                              ) then '김보배'
                          when c.short_name in ('AIG', 'DGL', 'HMF', 'HNF', 'HWF', 'MRA', 'MTL', 'PST'
                              ) then '조하연'
                          when c.short_name in ('ACF', 'AIL', 'CRF', 'SHL', 'TYL'
                              ) then '최우진'
                          end as worker
               from company c) w on w.short_name = c.short_name
where p.status = 'W'
  and cm_category.code_value in ('생활비 지급형', '첨단암치료비형', '암보험', '치아보험')
order by worker;

# 담당자별 남은 작업 - 상품 단위 (가설 개수 포함)
select w.worker,
       p.product_id,
       p.status,
       count(plms.plan_id)
from product p
         join plan_master plms on p.product_id = plms.product_id and plms.use_yn = 'Y'
         join code_master cm_category on cm_category.code = p.category
         join code_master cm_plan_category on cm_plan_category.code = plms.plan_category
         join company c on p.company_id = c.company_id
         join (select c.short_name,
                      case
                          when c.short_name in ('DBL', 'DBF', 'HNL', 'KLP', 'MGF'
                              ) then '김용준'
                          when c.short_name in ('ABL', 'AXF', 'HDF', 'HKL', 'HWL', 'LIN', 'LTF'
                              ) then '김인우'
                          when c.short_name in ('CBL', 'BPL', 'IBK'
                              ) then '손문수'
                          when c.short_name in ('HDL', 'SFI', 'SLI', 'PLI'
                              ) then '노우정'
                          when c.short_name in ('KBF', 'KBL', 'KDB', 'NHF', 'NHL'
                              ) then '박민철'
                          when c.short_name in ('KYO', 'MEZ'
                              ) then '김보배'
                          when c.short_name in ('AIG', 'DGL', 'HMF', 'HNF', 'HWF', 'MRA', 'MTL', 'PST'
                              ) then '조하연'
                          when c.short_name in ('ACF', 'AIL', 'CRF', 'SHL', 'TYL'
                              ) then '최우진'
                          end as worker
               from company c) w on w.short_name = c.short_name
where p.status = 'W'
  and cm_category.code_value in ('생활비 지급형', '첨단암치료비형', '암보험', '치아보험')
group by p.product_id
order by worker, p.product_id;

# 담당자별 남은 작업 - 가설 단위
select w.worker,
       p.product_id,
       p.status,
       cm_plan_category.code_value as 'plan_category',
       plms.plan_id
from product p
         join plan_master plms on p.product_id = plms.product_id and plms.use_yn = 'Y'
         join code_master cm_category on cm_category.code = p.category
         join code_master cm_plan_category on cm_plan_category.code = plms.plan_category
         join company c on p.company_id = c.company_id
         join (select c.short_name,
                      case
                          when c.short_name in ('DBL', 'DBF', 'HNL', 'KLP', 'MGF'
                              ) then '김용준'
                          when c.short_name in ('ABL', 'AXF', 'HDF', 'HKL', 'HWL', 'LIN', 'LTF'
                              ) then '김인우'
                          when c.short_name in ('CBL', 'BPL', 'IBK'
                              ) then '손문수'
                          when c.short_name in ('HDL', 'SFI', 'SLI', 'PLI'
                              ) then '노우정'
                          when c.short_name in ('KBF', 'KBL', 'KDB', 'NHF', 'NHL'
                              ) then '박민철'
                          when c.short_name in ('KYO', 'MEZ'
                              ) then '김보배'
                          when c.short_name in ('AIG', 'DGL', 'HMF', 'HNF', 'HWF', 'MRA', 'MTL', 'PST'
                              ) then '조하연'
                          when c.short_name in ('ACF', 'AIL', 'CRF', 'SHL', 'TYL'
                              ) then '최우진'
                          end as worker
               from company c) w on w.short_name = c.short_name
where p.status = 'W'
  and cm_category.code_value in ('생활비 지급형', '첨단암치료비형', '암보험', '치아보험')
order by worker, p.product_id;;