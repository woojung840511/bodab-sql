use fincette;

# 암, 치아 진행상황 보고
select
    result.product_category
, result.plan_category
, result.status
, result.`작업 구분`
, count(distinct product_id) as product_count
, count(distinct plan_id) as plan_count

from (select w.worker,
       cm_category.code_value as product_category,
       cm_plan_category.code_value as plan_category,
       p.product_id,
       p.status,
       plms.plan_id,
       case
        when p.status = 'W' then '작업중'
        when p.status = 'Y' and
             analysis.product_version != p.version then '버전업 필요'
        when p.status = 'Y' and
             analysis.product_version = p.version then '작업완료'
        when p.status in ('S') and
             analysis.product_version = p.version then '스탠바이'
        when p.status in ('S') and
             analysis.product_version = p.version then '스탠바이 => 작업중'
        when p.status in ('N') then '사용안함'
    end as '작업 구분',
       p.version as platform_version,
       analysis.product_version as analysis_version
from product p
         join plan_master plms on p.product_id = plms.product_id and plms.use_yn = 'Y' and plms.display_yn = 'Y'
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
         join (select max_p.product_code,
                      max_p.product_version
               from agr_product_main apm
                        join (select product_code,
                                     max(product_version) as product_version
                              from agr_product_main
                              where product_code not like '%_V0%'
                              group by product_code) max_p
                             on max_p.product_code = apm.product_code and
                                max_p.product_version = apm.product_version) analysis
              on analysis.product_code = p.product_id
  and cm_plan_category.code_value in ('생활비 지급형', '최신항암 치료비형', '암보험', '치아보험')
order by worker, p.product_id) result
group by result.plan_category, result.`작업 구분`;



# 담당자별 남은 작업 - 상품 단위 (가설 개수 포함) 최종
use fincette;

select
    result.worker,
    result.product_id,
    result.status,
    case
        when result.status = 'W' then '작업중'
        when result.status = 'Y' then '버전업 필요'
    end as '작업 구분',
    case
        when result.status = 'W' then result.w_plans
        when result.status = 'Y' then result.version_diff_plans
    end as '가입설계 개수',
    result.analysis_version as '현행화 버전',
    result.platform_version as '플렛폼 버전'

from (select w.worker,
       p.product_id,
       p.status,
       count(case when p.status = 'W' then plms.plan_id end) as w_plans,
       count(case when p.status = 'Y' and analysis.product_version != p.version then plms.plan_id end)
           as version_diff_plans,
       p.version as platform_version,
       analysis.product_version as analysis_version

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
         join (select max_p.product_code,
                      max_p.product_version
               from agr_product_main apm
                        join (select product_code,
                                     max(product_version) as product_version
                              from agr_product_main
                              where product_code not like '%_V0%'
                              group by product_code) max_p
                             on max_p.product_code = apm.product_code and
                                max_p.product_version = apm.product_version) analysis
              on analysis.product_code = p.product_id
                  where p.status in ('W', 'Y')
  and cm_category.code_value in ('생활비 지급형', '최신항암 치료비형', '암보험', '치아보험')

group by p.product_id
order by worker, p.product_id) result
where w_plans != 0 or version_diff_plans != 0
order by worker, status, product_id
;





-- 암, 치아 product 상품 상태별 개수 확인
select count(case
                 when cm_category.code_value in ('생활비 지급형', '최신항암 치료비형', '암보험') and p.status in ('S')
                     then 1 end) as '암보험 - 작업완료',
       count(case
                 when cm_category.code_value in ('생활비 지급형', '최신항암 치료비형', '암보험') and p.status in ('S', 'W')
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
  and cm_category.code_value in ('생활비 지급형', '최신항암 치료비형', '암보험', '치아보험')
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
  and cm_category.code_value in ('생활비 지급형', '최신항암 치료비형', '암보험', '치아보험')
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
  and cm_category.code_value in ('생활비 지급형', '최신항암 치료비형', '암보험', '치아보험')
order by worker, p.product_id;;