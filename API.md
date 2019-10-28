### 动漫之家 V3

#### API
1. 首页推荐分类信息
   
   url： `v3api.dmzj.com/recommend_new.json`
   
   method: GET
   
   content-type: json

    ```
    [{
        category_id: number,
        data: [
            {
               cover: string,
               obj_id:  string,
               status: string, // 连载中 已完结
               sub_title: string,
               title: string,
               type: number,
               url: string,
           }
        ],
        sort: number,
        title: string
    }]
    
2. 分类数据

    url： `v3api.dmzj.com/0/category.json`
    
    method: GET****
    
    content-type: json
    
    ```
    [{
        cover: string
        tag_id: number
        title: string
    }]
    ```
    
3. 最近更新 

    url： `v3api.dmzj.com/latest/100/{page}.json`
    
    method: GET
    
    content-type: json
    
    
    ```
    [{
         authors: string
         cover: string
         id: number
         islong: number
         last_update_chapter_id: number
         last_update_chapter_name: string
         last_updatetime: number
         status: string
         title: string
         types: string
     }]
    ```
   
4. 漫画详情

    url： `v3api.dmzj.com/comic/comic_{id}.json`
    
    method: GET
    
    content-type: json
    
    tip: 一页只会取 30 条数据
    
    ```
    [{
         authors: [
            {
                tag_id: number,
                tag_name: string
            }
         ],
         chapters: [
            {
                title: string,
                data: [
                    {
                        chapter_id: number
                        chapter_order: number
                        chapter_title: string 
                        filesize: number
                        updatetime: string
                    }
                ]
            }
         ],
         comic_py: string
         comment: {
            comment_count: number,
            latest_comment: [
                {
                   avatar: string,
                   comment_id: number,
                   content: string,
                   createtime: number,
                   nickname: string,
                   uid: number 
                }
            ]
         },
         copyright: number,
         cover: string,
         description: string,
         dh_url_links: object, // 因为动漫之家没有动画了，所以不打算列出来
         direction: number,
         first_letter: number,
         hidden: number,
         hit_num: number,
         hot_num: number,
         id: number,
         isHideChapter: string,
         is_dmzj: number,
         is_lock: number,
         islong: number,
         last_update_chapter_id: number,
         last_update_chapter_name: string,
         last_updatetime: number,
         status: [{
            tag_id: number,
            tag_name: string
         }],
         subscribe_num: number,
         title: string,
         types: [
            {
                tag_id: number,
                tag_name: string
             }
         ]
     }]
    ```
   
3. 漫画章节信息 

    url： `v3api.dmzj.com/chapter/{comic_id}/{chapter_id}.json`
    
    method: GET
    
    content-type: json
    
    ```
    {
        chapter_id: number,
        chapter_order: number,
        comic_id: number,
        comment_count: number,
        direction: number,
        page_url: string[],
    }
    ```

    
4. 漫画图片

    url: `imgsmall.dmzj.com/b/{comic_id}/{chapter_id}/{page}.jpg`

