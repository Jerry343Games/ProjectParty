using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MilkBoxSettings : MonoBehaviour
{
    public bool ableToTake;
    public BoxCollider boxCollider;
    public int playerOrder;
    public float existTime;
    public GameObject disableEffect;
    public Renderer rd;
    public static int bulletRemain;
    
    // Start is called before the first frame update
    void Start()
    {
        ableToTake = true;
        boxCollider = GetComponent<BoxCollider>();
        StartCoroutine(DisableMilkBox());
        if (gameObject.name == "Gun")
        {
            rd = gameObject.transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>();
        }
        bulletRemain = 6;
    }

    // Update is called once per frame
    void Update()
    {
        DisableInteract();
    }

    void DisableInteract()
    {
        if (!ableToTake)
        {
            boxCollider.enabled = false;
            if (gameObject.name == "Gun")
            {
                rd.enabled = false;
            }
        }
        else
        {
            boxCollider.enabled = true;
            if (gameObject.name == "Gun")
            {
                rd.enabled = true;
            }
        }
        
    }

    void BulletRemain()
    {
        if (bulletRemain == 0)
        {

            Destroy(gameObject);
        }
    }

    IEnumerator DisableMilkBox()
    {
        yield return new WaitForSeconds(existTime);
        Instantiate(disableEffect, transform.position, Quaternion.identity);
        
        if (ableToTake == true)
        {

            Destroy(gameObject);
        }
    }
}
