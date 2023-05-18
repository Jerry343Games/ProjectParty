using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class MilkCollect : MonoBehaviour
{
    public GameObject collectEffect;
    public GameObject disableEffect;
    public float existTime;
    // Start is called before the first frame update
    void Start()
    {
        Destroy(gameObject, existTime);
        StartCoroutine(EnableDisEffect());
        collectEffect = GameObject.Find("TreasureGrabWhite");
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            GameObject player = other.transform.parent.gameObject;
            int i = player.GetComponent<PlayerInput>().playerIndex;
            if (i == 0)
            {
                PlayerIndentify.scoreNum0++;//为自己加1
                SoundsManager.PlayCollectAudio();
                Instantiate(collectEffect, other.transform.position, Quaternion.identity);

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
                SoundsManager.PlayCollectAudio();
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
                SoundsManager.PlayCollectAudio();
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
                SoundsManager.PlayCollectAudio();
                PlayerIndentify.scoreNum3++;
                Instantiate(collectEffect, other.transform.position, Quaternion.identity);
                Debug.Log("collect3");
            }
            Destroy(gameObject);
        }
    }
    IEnumerator EnableDisEffect()
    {
        yield return new WaitForSeconds(existTime-0.05f);
        Instantiate(disableEffect, transform.position-new Vector3(0,1,0), Quaternion.identity);
    }
}
