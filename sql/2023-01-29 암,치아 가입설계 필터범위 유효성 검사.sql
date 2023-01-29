use fincette;

# 암, 치아보험 현재(2023-01-29) 기준 필터 유효범위 이탈한 가설 조회

select w.worker
     , p.product_id                   as product_id
     , p.product_name                 as product_name
     , plmp.plan_id                   as plan_id
     , cm_product_category.code_value as product_category -- 상품 카테고리
     , cm_plan_category.code_value    as plan_category    -- 플랜 카테고리
#      , p.status                         as status               -- 상품 상태
#      , plms.use_yn                      as plan_use_yn          -- 플랜 사용
#      , plms.display_yn                  as display_yn           -- 플랜 사용자화면표시
#      , plms.main_yn                     as main_yn              -- 대표가설
     , plms.min_ins_age               as min_ins_age      -- 가입최소나이(플랜)
     , plms.max_ins_age               as max_ins_age      -- 가입최대나이(플랜)
     , plms.plan_sub_name             as plan_sub_name    -- 원수사플랜명
     , plms.plan_type                 as plan_type        -- 플랜타입
     , plms.plan_type2                as plan_type2       -- 플랜타입2
     , plms.text_type                 as text_type        -- 텍스트타입
     , cm_product_kind.code_value     as product_kind     -- 환급형태
     , cm_product_type.code_value     as product_type     -- 갱신형태
     , cm_ins_term.code_value         as ins_term         -- 보험기간
     , cm_nap_term.code_value         as nap_term         -- 납입기간
     , cm_nap_cycle.code_value        as nap_cycle        -- 납입주기
#        , cm_assure_money.code_desc        as assure_money         -- 가입금액
#        , cm_annuity_age.code_value        as annuity_age          -- 연금개시나이
#        , cm_annuity_type.code_value       as annuity_type         -- 연금타입_종신형
#        , cm_fixed_annuity_type.code_value as fixed_annuity_type   -- 연급타입_확정형
from plan_mapper plmp
         join product_master pm on plmp.product_master_id = pm.product_master_id
         join product p on pm.product_id = p.product_id and p.status != 'N' -- 사용중인 상품
         join plan_master plms on plmp.plan_id = plms.plan_id and plms.use_yn = 'Y' and plms.display_yn = 'Y' -- 사용중인 가설
         join company c on p.company_id = c.company_id
         left outer join code_master cm_product_category on p.category = cm_product_category.code
         left outer join code_master cm_plan_category on plms.plan_category = cm_plan_category.code
         left outer join code_master cm_product_gubun on plmp.product_gubun = cm_product_gubun.code
         left outer join code_master cm_product_kind on plmp.product_kind = cm_product_kind.code
         left outer join code_master cm_product_type on plmp.product_type = cm_product_type.code
         left outer join code_master cm_nap_cycle on plmp.nap_cycle = cm_nap_cycle.code
         left outer join code_master cm_ins_term on plmp.ins_term = cm_ins_term.code
         left outer join code_master cm_nap_term on plmp.nap_term = cm_nap_term.code
         left outer join code_master cm_annuity_age on plmp.annuity_age = cm_annuity_age.code
         left outer join code_master cm_annuity_type on plmp.annuity_type = cm_annuity_type.code
         left outer join code_master cm_fixed_annuity_type
                         on plmp.fixed_annuity_type = cm_fixed_annuity_type.code
         left outer join code_master cm_assure_money on plmp.assure_money = cm_assure_money.code
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
where cm_product_gubun.code_value = '주계약'
  and cm_product_category.code_value in ('생활비 지급형', '최신항암 치료비형', '암보험', '치아보험')
  and cm_plan_category.code_value in ('생활비 지급형', '최신항암 치료비형', '암보험', '치아보험')
  and not (
      cm_plan_category.code_value in ('생활비 지급형', '최신항암 치료비형')
      or  (
                    cm_plan_category.code_value = '암보험'
                and (
                            plan_type like '기준 진단비형'
                            and (plan_type2 like '%1천만원%' or plan_type2 like '%3천만원%' or plan_type2 like '%5천만원%')
                            and (
                                    (
                                                cm_product_type.code_value = '갱신형' and
                                                (
                                                        (cm_ins_term.code_value in ('10년') and cm_nap_term.code_value in ('10년'))
                                                        or (cm_ins_term.code_value in ('15년') and cm_nap_term.code_value in ('15년'))
                                                        or (cm_ins_term.code_value in ('20년') and cm_nap_term.code_value in ('20년'))
                                                        or (cm_ins_term.code_value in ('30년') and cm_nap_term.code_value in ('30년'))
                                                    )
                                        ) or
                                    (
                                                cm_product_type.code_value = '비갱신형' and
                                                (
                                                        (cm_ins_term.code_value in ('80세') and cm_nap_term.code_value in ('10년', '20년'))
                                                        or (cm_ins_term.code_value in ('100세') and cm_nap_term.code_value in ('10년', '20년'))
                                                    )
                                        )
                                )
                        )
            )
        or (
                    cm_plan_category.code_value in ('치아보험')
                and (
                            (
                                    (
                                                plms.plan_type like '임플란트 100만원%' or
                                                plms.plan_type like '임플란트 200만원%'
                                        ) and
                                    (
                                                plms.plan_type2 like '크라운 미가입%' or
                                                plms.plan_type2 like '크라운 12.5만원%' or
                                                plms.plan_type2 like '크라운 20만원%' or
                                                plms.plan_type2 like '크라운 30만원%' or
                                                plms.plan_type2 like '크라운 50만원%'
                                        )
                                )
                            and (
                                (cm_ins_term.code_value in ('10년') and cm_nap_term.code_value in ('10년'))
                                or (cm_ins_term.code_value in ('15년') and cm_nap_term.code_value in ('15년'))

                                )
                        )
            )
    )
order by p.category, plms.plan_category, plms.plan_type, plms.plan_type2
;