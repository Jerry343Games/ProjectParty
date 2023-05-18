using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletHit : MonoBehaviour
{
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
        if (gameObject.GetComponent<Bullet>().isUnlocked)
        {
            if (other.tag == "Player")
            {
                Debug.Log("Hit");
                //other.transform.position = GetResetVolum();
                if (other.transform.parent.name == "Player 0")
                {
                    PlayerIndentify.scoreNum0 = PlayerIndentify.scoreNum0 - 2;
                    Debug.Log("Dead" + other.transform.parent.name + " " + PlayerIndentify.scoreNum0);
                    if (PlayerIndentify.scoreNum0 < 0)
                    {
                        PlayerIndentify.scoreNum0 = 0;
                        Debug.Log("Dead" + other.transform.parent.name + " " + PlayerIndentify.scoreNum0);
                    }

                }
                if (other.transform.parent.name == "Player 1")
                {
                    PlayerIndentify.scoreNum1 = PlayerIndentify.scoreNum1 - 2;
                    Debug.Log("Dead" + other.transform.parent.name + " " + PlayerIndentify.scoreNum1);
                    if (PlayerIndentify.scoreNum1 < 0)
                    {
                        PlayerIndentify.scoreNum1 = 0;
                        Debug.Log("Dead" + other.transform.parent.name + " " + PlayerIndentify.scoreNum1);
                    }

                }
                if (other.transform.parent.name == "Player 2")
                {
                    PlayerIndentify.scoreNum2 = PlayerIndentify.scoreNum2 - 2;
                    Debug.Log("Dead" + other.transform.parent.name + " " + PlayerIndentify.scoreNum2);
                    if (PlayerIndentify.scoreNum2 < 0)
                    {
                        PlayerIndentify.scoreNum2 = 0;
                        Debug.Log("Dead" + other.transform.parent.name + " " + PlayerIndentify.scoreNum2);
                    }

                }
            }
        }
    }
}
