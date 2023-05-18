using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class ObjectInstance : MonoBehaviour
{
    // Start is called before the first frame update

    [Header("待实例化物品")]
    public GameObject cannon;
    public GameObject milkBottle;

    [Header("放置地点")]
    public Transform[] cannonPos;
    public Transform[] milkPos;

    [Header("放置特效")]
    public GameObject cannonEffect;
    public GameObject milkEffect;

    [Header("触发时间(距游戏开始)")]
    public float cannonTime_1;
    public float milkTime_1;
    public float cannonTime_2;
    public float milkTime_2;
    public float finishTime;

    [Header("阶段计时UI")]
    public Color P_milkColor;
    public Color P_boomTimeColor;
    public Image ClockUI_Base;
    public Image ClockUI_Inner;
    public Sprite milkTexture;
    public Sprite boomTexture;
    public GameObject blackPanel;
    private float totalTime;
    [Header("UI动画")]
    public AnimationCurve showCurve;
    public AnimationCurve hideCurve;
    public float animationSpeed;
    public GameObject settlementPage;
    public Vector3 scale;

    [Header("是否取消生成物循环")]
    public bool disableCreat;

    bool doneMilk_1;
    bool doneMilk_2;
    bool doneCannon_1;
    bool doneCannon_2;
    bool fadeInDone;
    bool fadeOutDone;

    int recycleTime = 0;

    [Header("第二关")]
    public bool isScene2;
    public float scene2Time;
    public string nextLevelName;
    public bool isScene3;


    void Start()
    {
        doneMilk_1 = false;
        doneCannon_1 = false;
        doneMilk_2 = false;
        fadeInDone = false;
        fadeOutDone = false;

    }
    
    // Update is called once per frame
    void Update()
    {
        if (PlayerIndentify.isStartGame&&!disableCreat)
        {
            PlaceObject();
        }
        if (PlayerIndentify.isStartGame&&isScene2)
        {
            Scene2Count();
        }
    }

    void Scene2Count()
    {
        totalTime += Time.deltaTime;
        if (ClockUI_Base.fillAmount >= 0)
        {
            ClockUI_Base.fillAmount = 1 - (totalTime / scene2Time);
        }
        if (totalTime >= scene2Time)
        {
            blackPanel.GetComponent<UIFade>().UI_FadeIn_Event();
            if (blackPanel.GetComponent<CanvasGroup>().alpha > 0.9 && fadeInDone == false)
            {
                StartCoroutine(ShowCurve(settlementPage));
                fadeInDone = true;
                PlayerIndentify.isStartGame = false;
                
                if (!isScene3)
                {
                    StartCoroutine(waitToClose());
                    StartCoroutine(LoadNextLevel());
                }
                Debug.Log("ShowCurve");
            }
        }
    }

    void PlaceObject()
    {

        if (recycleTime != 2)
        {
            totalTime += Time.deltaTime;
            //第一轮：牛奶1
            if (!doneMilk_1)
            {
                Instantiate(milkBottle, milkPos[0].position, Quaternion.identity);
                Instantiate(milkBottle, milkPos[1].position, Quaternion.identity);
                doneMilk_1 = true;
                ClockUI_Base.color = P_milkColor;
                ClockUI_Inner.sprite = milkTexture;

            }
            //UI
            if (totalTime < cannonTime_1)
            {
                ClockUI_Base.fillAmount = totalTime / cannonTime_1;
            }

            //第二轮：加农炮1
            if (totalTime > cannonTime_1 && !doneCannon_1)
            {
                Instantiate(cannon, cannonPos[1].position, Quaternion.identity);
                Instantiate(cannon, cannonPos[0].position, Quaternion.Euler(0, 180, 0));
                Instantiate(cannonEffect, cannonPos[1].position+new Vector3(0,1,0), Quaternion.Euler(90, 0, 0));
                Instantiate(cannonEffect, cannonPos[0].position+new Vector3(0, 1, 0), Quaternion.Euler(90, 0, 0));
                doneCannon_1 = true;
                ClockUI_Base.color = P_boomTimeColor;
                ClockUI_Inner.sprite = boomTexture;
            }
            //UI
            if (totalTime >= cannonTime_1 && totalTime < milkTime_1)
            {
                ClockUI_Base.fillAmount = (totalTime - cannonTime_1) / (milkTime_1 - cannonTime_1);
            }

            //第三轮：牛奶2
            if (totalTime > milkTime_1 && !doneMilk_2)
            {
                Instantiate(milkBottle, milkPos[2].position, Quaternion.Euler(0, -90, 0));
                Instantiate(milkBottle, milkPos[3].position, Quaternion.Euler(0, -90, 0));
                
                doneMilk_2 = true;
                ClockUI_Base.color = P_milkColor;
                ClockUI_Inner.sprite = milkTexture;
            }
            //UI
            if (totalTime >= milkTime_1 && totalTime < cannonTime_2)//时间大于二次牛奶小于二次加农炮时间
            {
                ClockUI_Base.fillAmount = (totalTime - milkTime_1) / (cannonTime_2 - milkTime_1);
            }

            //第四轮：加农炮2
            if (totalTime > cannonTime_2 && !doneCannon_2)
            {
                Instantiate(cannon, cannonPos[2].position, Quaternion.Euler(0, 90, 0));
                Instantiate(cannon, cannonPos[3].position, Quaternion.Euler(0, -90, 0));
                Instantiate(cannonEffect, cannonPos[2].position + new Vector3(0, 1, 0), Quaternion.Euler(90, 0, 0));
                Instantiate(cannonEffect, cannonPos[3].position + new Vector3(0, 1, 0), Quaternion.Euler(90, 0, 0));
                doneCannon_2 = true;
                ClockUI_Base.color = P_boomTimeColor;
                ClockUI_Inner.sprite = boomTexture;
            }
            //UI
            if (totalTime >= cannonTime_2 && totalTime < milkTime_2)
            {
                ClockUI_Base.fillAmount = ((totalTime - cannonTime_2) / (milkTime_2 - cannonTime_2));
            }

            //结束 重设计时器
            if (totalTime >= milkTime_2 && recycleTime != 2)
            {
                totalTime = 0;
                doneMilk_1 = false;
                doneMilk_2 = false;
                doneCannon_1 = false;
                doneCannon_2 = false;
                recycleTime++;
                Debug.Log("RecycleTime" + recycleTime);
            }
        }
        if (recycleTime == 2)
        {
            blackPanel.GetComponent<UIFade>().UI_FadeIn_Event();
            if (blackPanel.GetComponent<CanvasGroup>().alpha > 0.9&&fadeInDone==false)
            {
                StartCoroutine(ShowCurve(settlementPage));
                StartCoroutine(waitToClose());
                StartCoroutine(LoadNextLevel());
                fadeInDone = true;
                PlayerIndentify.isStartGame = false;
                Debug.Log("ShowCurve");
            }
        }
    }

    IEnumerator waitToClose()
    {
        yield return new WaitForSeconds(3.2f);
        PlayerIndentify.gameDone = true;
    }
    IEnumerator LoadNextLevel()
    {
        yield return new WaitForSeconds(4f);
        SceneManager.LoadScene(nextLevelName);
    }

    IEnumerator ShowCurve(GameObject gameObject)
    {
        float timer = 0;
        while (timer <= 1)
        {
            gameObject.transform.localScale = scale * showCurve.Evaluate(timer);
            timer += Time.deltaTime * animationSpeed;
            yield return null;
        }
    }

    IEnumerator HideCurve(GameObject gameObject)
    {
        float timer = 0;
        while (timer <= 1)
        {
            gameObject.transform.localScale = scale * hideCurve.Evaluate(timer);
            timer += Time.deltaTime * animationSpeed;
            yield return null;
        }
    }
}
