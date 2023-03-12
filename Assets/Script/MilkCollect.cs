using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class MilkCollect : MonoBehaviour
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
        GameObject player = other.transform.parent.gameObject;
        int i = player.GetComponent<PlayerInput>().playerIndex;
        if (i == 0)
        {
            PlayerIndentify.scoreNum0++;
            Debug.Log("collect0");
            if (PlayerMovement.linked02)
            {
                PlayerIndentify.scoreNum2++;
            }
            if (PlayerMovement.linked01)
            {
                PlayerIndentify.scoreNum1++;
            }
        }
        if (i == 1)
        {
            PlayerIndentify.scoreNum1++;
            Debug.Log("collect1");
            if (PlayerMovement.linked12)
            {
                PlayerIndentify.scoreNum2++;
            }
            if (PlayerMovement.linked01)
            {
                PlayerIndentify.scoreNum0++;
            }
        }
        if (i == 2)
        {
            PlayerIndentify.scoreNum2++;
            Debug.Log("collect2");
            if (PlayerMovement.linked02)
            {
                PlayerIndentify.scoreNum0++;
            }
            if (PlayerMovement.linked12)
            {
                PlayerIndentify.scoreNum1++;
            }
        }
        if (i == 3)
        {
            PlayerIndentify.scoreNum3++;
            Debug.Log("collect3");
        }
            Destroy(gameObject);
    }
}
