using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class MilkCollect : MonoBehaviour
{
    public GameObject collectEffect;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
        GameObject player = other.transform.parent.gameObject;
        int i = player.GetComponent<PlayerInput>().playerIndex;
        if (i == 0)
        {
            PlayerIndentify.scoreNum0++;//为自己加1
            Instantiate(collectEffect, other.transform.position,Quaternion.identity);
            //判断连接情况为队友加分
            if (PlayerMovement.linked02)
            {
                Transform friend = GameObject.Find("Player 2").transform.GetChild(0);
                PlayerIndentify.scoreNum2++;
                Instantiate(collectEffect, friend.position, Quaternion.identity);
            }
            if (PlayerMovement.linked01)
            {
                Transform friend = GameObject.Find("Player 1").transform.GetChild(0);
                PlayerIndentify.scoreNum1++;
                Instantiate(collectEffect, friend.position, Quaternion.identity);
            }
        }
        if (i == 1)
        {
            PlayerIndentify.scoreNum1++;
            Instantiate(collectEffect, other.transform.position, Quaternion.identity);
            Debug.Log("collect1");
            if (PlayerMovement.linked12)
            {
                Transform friend = GameObject.Find("Player 2").transform.GetChild(0);
                Instantiate(collectEffect, friend.position, Quaternion.identity);
                PlayerIndentify.scoreNum2++;
            }
            if (PlayerMovement.linked01)
            {
                Transform friend = GameObject.Find("Player 0").transform.GetChild(0);
                Instantiate(collectEffect, friend.position, Quaternion.identity);
                PlayerIndentify.scoreNum0++;
            }
        }
        if (i == 2)
        {
            PlayerIndentify.scoreNum2++;
            Instantiate(collectEffect, other.transform.position, Quaternion.identity);
            Debug.Log("collect2");
            if (PlayerMovement.linked02)
            {
                Transform friend = GameObject.Find("Player 0").transform.GetChild(0);
                Instantiate(collectEffect, friend.position, Quaternion.identity);
                PlayerIndentify.scoreNum0++;
            }
            if (PlayerMovement.linked12)
            {
                Transform friend = GameObject.Find("Player 1").transform.GetChild(0);
                Instantiate(collectEffect, friend.position, Quaternion.identity);
                PlayerIndentify.scoreNum1++;
            }
        }
        if (i == 3)
        {
            PlayerIndentify.scoreNum3++;
            Instantiate(collectEffect, other.transform.position, Quaternion.identity);
            Debug.Log("collect3");
        }
            Destroy(gameObject);
    }
}
