using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerPositionConfirm : MonoBehaviour
{
    // Start is called before the first frame update

    private GameObject player0;
    private GameObject player1;
    private GameObject player2;
    private GameObject player3;

    public GameObject[] StartPoint;
    bool hasFind;
    void Start()
    {
        hasFind = false;
        StartCoroutine(ResetPlayerPosition());
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void FindAndSetPlayers()
    {
        if(player0 = GameObject.Find("Player 0"))
        {
            player0.transform.position = StartPoint[0].transform.position;
            player0.transform.GetChild(0).transform.position = StartPoint[0].transform.position;
            Debug.Log("Set p0");
        }
        if(player1 = GameObject.Find("Player 1"))
        {
            player1.transform.position = StartPoint[1].transform.position;
            player1.transform.GetChild(0).transform.position = StartPoint[1].transform.position;
            Debug.Log("Set p1");
        }
        if(player2 = GameObject.Find("Player 2"))
        {
            player2.transform.position = StartPoint[2].transform.position;
            player2.transform.GetChild(0).transform.position = StartPoint[2].transform.position;
            Debug.Log("Set p2");
        }
        if(player3 = GameObject.Find("Player 3"))
        {
            player3.transform.position = StartPoint[3].transform.position;
            player3.transform.GetChild(0).transform.position = StartPoint[3].transform.position;
            Debug.Log("Set p3");
        }
        hasFind = true;
        
    }

    IEnumerator ResetPlayerPosition()
    {
        yield return new WaitForSeconds(0.1f);
        FindAndSetPlayers();
    }
}
