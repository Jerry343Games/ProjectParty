using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AttachArea : MonoBehaviour
{
    // Start is called before the first frame update
    public float m_Radius;
    bool isMagnet;
    public static string playerName;
    public GameObject model;
    public GameObject effect;
    private Transform player;
    public float continueTime;
    bool hasTriggered;
    void Start()
    {
        isMagnet = false;
        hasTriggered = false;
        effect.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {
        Attach();
    }

    void Attach()
    {
        if (isMagnet&&hasTriggered)
        {
            transform.parent = player;
            effect.transform.position = player.position;
            //effect.transform.parent = player;
            //检测以玩家为球心半径是5的范围内的所有的带有碰撞器的游戏对象
            Collider[] colliders = Physics.OverlapSphere(transform.position, m_Radius);
            foreach (var item in colliders)
            {
                //如果是金币
                if (item.tag=="Milk")
                {
                    Debug.Log(item.name);
                    //让金币的开始移动
                    item.GetComponent<CoinMoveController>().isCanMove = true;
                }
            }

        }
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player"&&!hasTriggered)
        {
            playerName = other.transform.parent.name;
            player = other.transform;
            model.SetActive(false);
            isMagnet = true;
            effect.SetActive(true);
            StartCoroutine(WaitToDestory());
            Debug.Log("Mag!");
            hasTriggered = true;
        }
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position , m_Radius);
    }

    IEnumerator WaitToDestory()
    {
        yield return new WaitForSeconds(continueTime);
        Destroy(gameObject);
    }
}
