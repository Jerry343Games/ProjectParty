using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class PlayerIndentify : MonoBehaviour
{
    public GameObject switchPanel;
    private float switchPercent;
    private Material mat;
    private bool closeDone;
    private bool openDone;
    public static bool gameDone;

    //寻找场内的所有玩家
    private GameObject player0;
    private GameObject player1;
    private GameObject player2;

    private Transform model0;
    private Transform model1;
    private Transform model2;
    //存储玩家间距离
    float distance01;
    float distance02;
    float distance12;

    //圆圈缩放值
    public Vector3 circleScale;
    //可连接距离和可连接状态
    public float linkDistance;
    public static bool link0_1;
    public static bool link0_2;
    public static bool link1_2;

    //玩家人数判断
    public int totalNum;
    public static int staticTotalNum;
    public static int pNum;
    public static bool isStartGame;
    public GameObject HeaderPage;
    private GameObject blackPanel;
    private bool disableBlackPanel;

    //储存所有绳子
    public GameObject rope01;
    public GameObject rope02;
    public GameObject rope12;
    bool hasSetAll;

    public GameObject[] interactor;

    //计分功能
    public Text[] scoreNumText;
    public Text[] endScoreNumText;
    public bool isFirstScene;
    public Text countTime;
    private float nowtime=6;
    private int s;
    public static int scoreNum0;
    public static int scoreNum1;
    public static int scoreNum2;
    public static int scoreNum3;

    // Start is called before the first frame update
    void Start()
    {
        isStartGame=false;
        staticTotalNum = totalNum;
        pNum = 0;
        if (isFirstScene)
        {
            scoreNum0 = 0;
            scoreNum1 = 0;
            scoreNum2 = 0;
            scoreNum3 = 0;
        }
        blackPanel = GameObject.Find("BlackPanel");
        mat=switchPanel.GetComponent<Image>().material;
        switchPercent = mat.GetFloat("_Per");
        switchPercent = 0;
        openDone = false;
        closeDone = true;
        gameDone = false;
    }

    // Update is called once per frame
    void Update()
    {
        DetectDistance();
        EvaluatePlayerNum();
        if (isStartGame)
        {
            SetRopes();
        }
        SetGrassInteracyor();
        ScoreCaculate();
        //Debug.Log(link0_1);
        ResetRopes();
        FindRopes();

        OpenSwitchPanel();
        CloseSwitchPanel();
    }

    private void OpenSwitchPanel()
    {
        if (!openDone) {
            if (switchPercent < 1)
            {
                switchPercent += Time.deltaTime * (1 / 0.5f);
                mat.SetFloat("_Per", switchPercent);
                Debug.Log("isOpening");
            }
            if (switchPercent >= 1)
            {
                openDone = true;
            }
        }
    }

    private void CloseSwitchPanel()
    {
        if (gameDone && openDone)
        {
            if (switchPercent>0) {
                switchPercent -= Time.deltaTime * (1 / 0.5f);
                mat.SetFloat("_Per", switchPercent);
            }
        }
    }

    private void DetectDistance()
    {
        if (totalNum == 3)
        {
            player0 = GameObject.Find("Player 0");
            if (!player0)
            {
                Debug.Log("lost p0");
                return;
            }
            player1 = GameObject.Find("Player 1");
            if (!player1)
            {
                Debug.Log("lost p1");
                return;
            }
            player2 = GameObject.Find("Player 2");
            if (!player2)
            {
                Debug.Log("lost p2");
                return;
            }
        }
        if (totalNum == 2)
        {
            player0 = GameObject.Find("Player 0");
            if (!player0)
            {
                Debug.Log("lost p0");
                return;
            }
            player1 = GameObject.Find("Player 1");
            if (!player1)
            {
                Debug.Log("lost p1");
                return;
            }
        }

        //3玩家
        if (totalNum == 3)
        {
            model0 = FindModel(player0);
            model1 = FindModel(player1);
            model2 = FindModel(player2);

            distance01 = (FindModel(player0).position - FindModel(player1).position).sqrMagnitude;//0-1
            distance02 = (FindModel(player0).position - FindModel(player2).position).sqrMagnitude;//0-2
            distance12 = (FindModel(player1).position - FindModel(player2).position).sqrMagnitude;//1-2

            if (distance01 <= linkDistance && distance02 > linkDistance && distance12 > linkDistance)
            {
                //FindCircle(player0).localScale = circleScale;
                //FindCircle(player1).localScale = circleScale;
                FindCircle(player2).localScale = new Vector3(0, 0, 0);
                link0_1 = true;
                link0_2 = false;
                link1_2 = false;
            }
            if (distance01 <= linkDistance && distance02 <= linkDistance && distance12 > linkDistance)
            {
                //FindCircle(player0).localScale = circleScale;
                //FindCircle(player1).localScale = circleScale;
                //FindCircle(player2).localScale = circleScale;
                link0_1 = true;
                link0_2 = true;
                link1_2 = false;
            }

            if (distance01 <= linkDistance && distance02 <= linkDistance && distance12 <= linkDistance)
            {
                //FindCircle(player0).localScale = circleScale;
                //FindCircle(player1).localScale = circleScale;
                //FindCircle(player2).localScale = circleScale;
                link0_1 = true;
                link0_2 = true;
                link1_2 = true;

            }
            if (distance01 > linkDistance && distance02 > linkDistance && distance12 > linkDistance)
            {
                //FindCircle(player0).localScale = new Vector3(0, 0, 0);
                //FindCircle(player1).localScale = new Vector3(0, 0, 0);
                //FindCircle(player2).localScale = new Vector3(0, 0, 0);
                Debug.Log(0);
                link0_1 = false;
                link0_2 = false;
                link1_2 = false;
            }

            if (distance01 > linkDistance && distance02 <= linkDistance && distance12 > linkDistance)
            {
                //FindCircle(player0).localScale = circleScale;
                //FindCircle(player1).localScale = new Vector3(0, 0, 0);
                //FindCircle(player2).localScale = circleScale;
                link0_1 = false;
                link0_2 = true;
                link1_2 = false;

            }
            if (distance01 > linkDistance && distance02 <= linkDistance && distance12 <= linkDistance)
            {
                //FindCircle(player0).localScale = circleScale;
                //FindCircle(player1).localScale = circleScale;
                //FindCircle(player2).localScale = circleScale;
                link0_1 = false;
                link0_2 = true;
                link1_2 = true;
            }
            if (distance01 > linkDistance && distance02 > linkDistance && distance12 <= linkDistance)
            {
                //FindCircle(player0).localScale = new Vector3(0, 0, 0);
                //FindCircle(player1).localScale = circleScale;
                //FindCircle(player2).localScale = circleScale;
                link0_1 = false;
                link0_2 = false;
                link1_2 = true;
            }
        }

        //2玩家
        if (totalNum == 2)
        {
            model0 = FindModel(player0);
            model1 = FindModel(player1);

            distance01 = (FindModel(player0).position - FindModel(player1).position).sqrMagnitude;//0-1

            if (distance01 <= linkDistance)
            {
                //FindCircle(player0).localScale = circleScale;
                //FindCircle(player1).localScale = circleScale;
                link0_1 = true;
            }
            else
            {
                //FindCircle(player0).localScale = new Vector3(0, 0, 0);
                //FindCircle(player1).localScale = new Vector3(0, 0, 0);
                link0_1 = false;
            }
        }

    }

    Transform FindModel(GameObject father)
    {
        Transform[] trans = father.GetComponentsInChildren<Transform>(true);
        return trans[1];
    }

    Transform  FindCircle(GameObject father)
    {
        Transform[] trans = father.GetComponentsInChildren<Transform>(true);
        return trans[4];
    }

    void EvaluatePlayerNum()
    {
        if (pNum == totalNum&&!isStartGame)
        {
            StartCoroutine(WaitForStart());
            if (nowtime >= 0)
            {
                countTime.fontSize = 38;
                nowtime -= Time.deltaTime;
                s = (int)nowtime % 60; //小数转整数 
                countTime.text = s.ToString();
            }
            Debug.Log("Able To Start");
        }
        if (isStartGame)
        {
            HeaderPage.GetComponent<UIFade>().UI_FadeOut_Event();
            //HeaderPage.SetActive(false);

        }
        if (disableBlackPanel)
        {
            blackPanel.GetComponent<UIFade>().UI_FadeOut_Event();
            if (blackPanel.GetComponent<CanvasGroup>().alpha == 0)
            {
                Debug.Log("BlackPanelDisabled");
                disableBlackPanel = false;
            }
        }
    }

    private void ResetRopes()
    {
        if (rope12.activeSelf == false)
        {
            //Debug.Log("........");
            rope12.GetComponent<RopeToolkit.Rope>().code = true;
        }
        if (rope12.activeSelf == true)
        {
            rope12.GetComponent<RopeToolkit.Rope>().code = false;
        }
    }

    void FindRopes()
    {
        rope01 = FindObject2("Ropes", "Rope 0-1");
        rope02 = FindObject2("Ropes", "Rope 0-2");
        rope12 = FindObject2("Ropes", "Rope 1-2");
    }

    void SetRopes()
    {
        if (totalNum == 3)
        {

            rope01.GetComponent<RopeToolkit.Rope>().spawnPoints[0] = model0.position;
            rope01.GetComponent<RopeToolkit.Rope>().spawnPoints[1] = new Vector3(model0.position.x + 0.25f, model0.position.y, model0.position.z + 0.5f);
            rope01.GetComponent<RopeToolkit.Rope>().spawnPoints[2] = new Vector3(model1.position.x + 0.25f, model1.position.y, model1.position.z + 0.5f);
            rope01.GetComponent<RopeToolkit.Rope>().spawnPoints[3] = model1.position;

            rope02.GetComponent<RopeToolkit.Rope>().spawnPoints[0] = model0.position;
            rope02.GetComponent<RopeToolkit.Rope>().spawnPoints[1] = new Vector3(model0.position.x + 0.25f, model0.position.y, model0.position.z + 0.5f);
            rope02.GetComponent<RopeToolkit.Rope>().spawnPoints[2] = new Vector3(model2.position.x + 0.25f, model2.position.y, model2.position.z + 0.5f);
            rope02.GetComponent<RopeToolkit.Rope>().spawnPoints[3] = model2.position;

            rope12.GetComponent<RopeToolkit.Rope>().spawnPoints[0] = model1.position;
            rope12.GetComponent<RopeToolkit.Rope>().spawnPoints[1] = new Vector3(model1.position.x + 0.25f, model1.position.y, model1.position.z + 0.5f);
            rope12.GetComponent<RopeToolkit.Rope>().spawnPoints[2] = new Vector3(model2.position.x + 0.25f, model2.position.y, model2.position.z + 0.5f);
            rope12.GetComponent<RopeToolkit.Rope>().spawnPoints[3] = model2.position;

            hasSetAll = true;
        }
        if (totalNum == 2)
        {
            rope01.GetComponent<RopeToolkit.Rope>().spawnPoints[0] = model0.position;
            rope01.GetComponent<RopeToolkit.Rope>().spawnPoints[1] = new Vector3(model0.position.x + 0.25f, model0.position.y, model0.position.z + 0.5f);
            rope01.GetComponent<RopeToolkit.Rope>().spawnPoints[2] = new Vector3(model1.position.x + 0.25f, model1.position.y, model1.position.z + 0.5f);
            rope01.GetComponent<RopeToolkit.Rope>().spawnPoints[3] = model1.position;

            hasSetAll = true;
        }
  
    }

    private Vector3 GetBetweenPoint(Vector3 start, Vector3 end, float percent = 0.5f)
    {
        Vector3 normal = (end - start).normalized;
        float distance = Vector3.Distance(start, end);
        return normal * (distance * percent) + start;
    }


    void SetGrassInteracyor()
    {

        if (isStartGame && totalNum==3)
        {
            interactor[0].transform.position = model0.position;
            interactor[1].transform.position = model1.position;
            interactor[2].transform.position = model2.position;
        }
        if (isStartGame && totalNum == 2)
        {
            interactor[0].transform.position = model0.position;
            interactor[1].transform.position = model1.position;
        }
    }

    void ScoreCaculate()
    {
        if(isStartGame && totalNum == 4)
        {
            scoreNumText[0].text = scoreNum0.ToString();
            scoreNumText[1].text = scoreNum1.ToString();
            scoreNumText[2].text = scoreNum2.ToString();
            scoreNumText[3].text = scoreNum3.ToString();
            endScoreNumText[0].text = scoreNum0.ToString();
            endScoreNumText[1].text = scoreNum1.ToString();
            endScoreNumText[2].text = scoreNum2.ToString();
            endScoreNumText[3].text = scoreNum3.ToString();

        }
        if (isStartGame&&totalNum==3)
        {
            scoreNumText[0].text = scoreNum0.ToString();
            scoreNumText[1].text = scoreNum1.ToString();
            scoreNumText[2].text = scoreNum2.ToString();
            endScoreNumText[0].text = scoreNum0.ToString();
            endScoreNumText[1].text = scoreNum1.ToString();
            endScoreNumText[2].text = scoreNum2.ToString();
        }
        if (isStartGame && totalNum == 2)
        {
            scoreNumText[0].text = scoreNum0.ToString();
            scoreNumText[1].text = scoreNum1.ToString();
            endScoreNumText[0].text = scoreNum0.ToString();
            endScoreNumText[1].text = scoreNum1.ToString();
        }
    }

    void Count3Seconds()
    {

    }

    IEnumerator WaitForStart()
    {
        yield return new WaitForSeconds(6f);
        disableBlackPanel = true;
        isStartGame = true;

    }
    public void ReStartScene3_0()
    {
        SceneManager.LoadScene("RopeTest");
    }

    public void RestartScene2_0()
    {
        SceneManager.LoadScene("Scene_2p_0");
    }

    public void BackMenu()
    {
        SceneManager.LoadScene("StartPage");
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.DrawSphere(rope12.GetComponent<RopeToolkit.Rope>().spawnPoints[0], 5);
        Gizmos.DrawSphere(rope12.GetComponent<RopeToolkit.Rope>().spawnPoints[1], 5);
        Gizmos.DrawSphere(rope12.GetComponent<RopeToolkit.Rope>().spawnPoints[2], 5);
        Gizmos.DrawSphere(rope12.GetComponent<RopeToolkit.Rope>().spawnPoints[3], 5);
    }
    private static GameObject FindObject2(string parentName, string childName)
    {
        GameObject parentObj = GameObject.Find(parentName);
        GameObject bbb = parentObj.transform.Find(childName).gameObject;
        return bbb;
    }
}
